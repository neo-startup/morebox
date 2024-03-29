class ApisController < ApplicationController
  before_action :authenticate_user!, only: %i(pay_url)
  skip_before_action :verify_authenticity_token

  # 부트페이 버전
  def pay_url
    @result = false
    @item = Item.find_by(id: params[:item_id])
    subitem_info = params[:subitem_info].present? ? params[:subitem_info]&.reject{|_, v| v == "0"} : nil
    
    @subitems = SubItem.where(id: subitem_info&.keys)
    #1. 토큰 발급받기
    bootpay = Bootpay::ServerApi.new(
        "5eb2230002f57e002d1edd8d",
        "GAx0ZCkgGIZuKMlfLgWDbOpAlpSVYV5IWXdmBKURELg="
    )
    result = bootpay.get_access_token

    #2. 결제 링크 생성하기
    if (@subitems.presence || @item) && (result[:status] == 200)
      require 'securerandom'
      random_string = SecureRandom.hex(3)
      order_number = "#{random_string}#{Time.current.to_i}"

      if @subitems.present?
        title = "#{@subitems.first.title} 포함 #{@subitems.count}개 직접구매"
        total_price = 0
        items = []
        @subitems.each do |subitem|
          quantity = subitem_info&.dig(subitem.id.to_s)&.to_i
          price = subitem.point * quantity
          total_price = total_price + price
          items << {
                    item_name: subitem.title,
                    qty: quantity,
                    unique: subitem.id,
                    price: price
                  }
        end
      else
        title = @item.title
        total_price = @item.price
        items = [{
                  item_name: @item.title,
                  qty: 1,
                  unique: @item.id,
                  price: @item.price
                }]
      end

      @trainer = User.manager.where(gym: current_gym).where.not(id: current_user&.id).where("phone like ?", "%#{params[:trainer_code]}").first
      if (params[:trainer_code].blank? || @trainer)
        if check_gym_tablet
          response = bootpay.request_payment(
            pg: 'inicis', # PG Alias
            method: 'card', # Method Alias
            order_id: order_number, # 사용할 OrderId
            price: total_price, # 결제금액
            items: items,
            name: "#{title}", # 상품명
            params: {
              user_id: current_user.id
            },
            # return_url: "http://172.30.1.34:3003/users/#{current_user.id}/pay_complete"
            return_url: "https://morebox.co.kr/users/#{current_user.id}/pay_complete"
          )
          if (order = current_user.orders.create(status: :ready, gym: current_gym, item: @item, order_number: order_number, trainer: @trainer))
            @subitems.each do |sub_item|
              order.order_sub_items.new(quantity: subitem_info&.dig(sub_item.id.to_s)&.to_i, sub_item: sub_item)
            end
            order.save
            link = response[:data]
            receiver = current_user.phone
            receiverName = current_user.phone.last(4)
            subject = "모어박스 결제"
            contents = "[MoreBox]\n"+"#{link}"+" 아이폰 유저는 결제 후 뒤로 돌아가주세요"
            payment_alarm = MessageAlarmService.new(receiver, receiverName, subject, contents)
            payment_alarm.send_message if Rails.env.production?
            @result = true
            # redirect_to items_path, notice: "결제 생성에 실패하였습니다. 다시한번 시도해주세요."
          end
        else
          if (@order = current_user.orders.create(status: :ready, gym: current_gym, item: @item, order_number: order_number, trainer: @trainer, total: total_price))
            @subitems.each do |sub_item|
              @order.order_sub_items.new(quantity: subitem_info&.dig(sub_item.id.to_s)&.to_i, sub_item: sub_item)
            end
            @order.save
            @result = true
          end
        end
      else
        @result = "no_trainer"
      end
    end
  end

  def pay_complete
    user = nil
    order = nil

    begin
      receipt_id = params[:receipt_id]
      require 'bootpay-rest-client'
      bootpay = Bootpay::ServerApi.new(
          "5eb2230002f57e002d1edd8d",
          "GAx0ZCkgGIZuKMlfLgWDbOpAlpSVYV5IWXdmBKURELg="
      )
      result  = bootpay.get_access_token
      # msg = "결제가 실패하였습니다. 다시 한번 시도해주세요."
      if (result[:status]&.to_s == "200")
        order_number = params[:order_id]
        order = Order.find_by(order_number: order_number)
        verify_response = bootpay.verify(receipt_id) unless Rails.env.development?
        user = order.user

        if order && (Rails.env.development? || (verify_response[:status]&.to_s == "200") && (verify_response.dig(:data, :status)&.to_s == "1"))
          total_price = 0
          if order.item
            total_price = order.item&.price
          else
            total_price = order.order_sub_items&.inject(0){|sum, order_sub_item| sum + (order_sub_item.quantity * order_sub_item&.sub_item&.point)}
          end
          if (Rails.env.development? || ((item = order.item) || order.sub_items&.exists?) && (verify_response[:data][:price] == total_price))
            if order.ready?
              point = nil
              data_type = "payment_complete"
              amount = 0

              if order.item
                amount = order.trainer ? (order.item&.point + (total_price.to_f * 0.05)) : order.item&.point
              else
                data_type = "direct_complete"
                amount = order.order_sub_items&.inject(0){|sum, order_sub_item| sum + (order_sub_item.quantity * order_sub_item&.sub_item&.point)}
              end

              if (point = Point.create(amount: amount, point_type: :charged, user: user, gym: current_gym))
                order.update(status: :complete, paid_at: Time.zone.now, point: point, payment_amount: total_price)
                ActionCable.server.broadcast("room_#{user.id}", data_type: data_type)
              else
                # msg = "포인트 생성에 실패하였습니다. 관리자에게 문의해주세요."
                raise
              end
            else
              # msg = "이미 결제가 된 상품입니다."
              raise
            end
            title = item&.title || "#{order.sub_items.first&.title} 포함 #{order.sub_items.count}개 상품"

            # 관리자 결제 알람
            templateCode = '020100000007'
            content = user.gym.title + " " + user.phone.last(4) + "님의 " + title + " 결제가 완료되었습니다."
            receiver = '010-5605-3087'
            receiverName = '박진배'
            admin_alarm = KakaoAlarmService.new(templateCode, content, receiver, receiverName)
            admin_alarm.send_alarm if Rails.env.production?

            # 결제한 사용자에게 알람
            templateCode = '020100000008'
            content = "[MoreMarket]\n정상적으로 결제 되었습니다!\n\n이제 휴대폰 창을 끄시고 헬스장에\n있는 태블릿으로 체크인 하시면 됩니다:)\n\n당신의 땀을 가치있게 만들겠습니다.\n\n\n버튼 클릭하시고 자사몰도 구경하세요!!!"
            receiver = user.phone
            receiverName = user.phone.last(4)
            user_alarm = KakaoAlarmService.new(templateCode, content, receiver, receiverName)
            user_alarm.send_alarm

          else
            raise
          end
        else
          raise
        end
      else
        raise
      end
      render html: "OK"
    rescue
      if order && order.user && order.ready? && false
        order.incomplete!
        receiver = user.phone
        receiverName = user.phone.last(4)
        contents = "[MoreBox]\n"+"#{msg}\n"
        payment_alarm = MessageAlarmService.new(receiver, receiverName, contents)
        payment_alarm.send_mms
      end
      ActionCable.server.broadcast("room_#{user.id}", data_type: "cancel") if user

      respond_to do |format|
        format.json { render json: {result: false} }
      end
    end
  end

  # def pay_url
  #   # 카카오페이 버전
  #   item = Item.find_by(id: params[:item_id])
  #   gym = Gym.find_by(id: params[:gym_id])
  #   if item && gym
  #     response = HTTParty.post(
  #       "https://kapi.kakao.com/v1/payment/ready",
  #       headers: {
  #         Authorization: "KakaoAK f348a6522071ea17f9dabce9a88b0744"
  #       },
  #       body: {
  #         cid: "CT24824054",
  #         # cid: "TC0ONETIME",
  #         partner_order_id: "#{gym.id}", # 가맹점 주문 번호
  #         partner_user_id: "#{current_user.id}", # 가맹점 회원 id
  #         item_name: "#{item.title}",
  #         quantity: 1,
  #         total_amount: item.price,
  #         vat_amount: 0,
  #         tax_free_amount: 0,
  #         # approval_url: "http://localhost:3000/orders/payment?item_id=#{item.id}",
  #         approval_url: "https://morebox.co.kr/orders/payment?item_id=#{item.id}",
  #         # fail_url: 'http://localhost:3000/',
  #         fail_url: 'https://morebox.co.kr/',
  #         # cancel_url: 'http://localhost:3000/',
  #         cancel_url: 'https://morebox.co.kr/'
  #       }
  #     )
  #
  #     data = response.parsed_response
  #     cookies[:tid] = data.first.second
  #     render json: data
  #   else
  #     render json: {result: false}
  #   end
  # end
end
