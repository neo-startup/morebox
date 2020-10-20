class PostsController < ApplicationController
  def index
  end

  def create
    post = Post.create(post_params)

    link = "http://pf.kakao.com/_WlPxlK/chat"
    receiver = params[:phone]
    receiverName = post.name
    subject = "당신만을 위한 영양 상담"
    contents = "[모어코치]\n"+"#{link}"+"\n 위 링크에 접속하셔서 '상담 시작'이라고 카톡을 보내주세요:)"
    nutrition_alarm = MessageAlarmService.new(receiver, receiverName, subject, contents)
    nutrition_alarm.send_message

    receiver = '010-5605-3087'
    receiverName = "박진배"
    subject = "우와 누가 상담했어"
    contents = "누가 상담 요청을 했습니다!"
    nutrition_admin_alarm = MessageAlarmService.new(receiver, receiverName, subject, contents)
    nutrition_admin_alarm.send_message

    redirect_to complete_posts_path
  end

  def complete
  end

  private
  def post_params
    params.require(:post).permit(:age, :height, :weight, :gender, :activity, :work_time, :work_count, :target_weight, :target_date, :lunch, :name)
  end
end