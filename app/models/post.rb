class Post < ApplicationRecord
  enum gender: %i(여 남)
  enum activity: %i(대부분앉아있는다 조금활동적인편이다 돌아다닐일이많다 많이활동한다 매우메우활동적이다)
  enum lunch: %i(안먹는다 간단하게 평균적으로 푸짐하게)
  enum work_strength: %i(저강도 중강도 고강도)
  enum post_type: %i(저스트 풀케어)
  # enum is_morebox: %i(아니오 예)
  enum payment: %i(아니오 예)
  enum counsel_time: %i(오전10시 오전11시 오후12시 오후1시 오후2시 오후3시 오후4시 오후5시 오후6시 오후7시)
end
