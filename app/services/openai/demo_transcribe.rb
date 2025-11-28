module Openai
  class DemoTranscribe < ActiveInteraction::Base
    object :call_recording, class: CallRecording

    validate :validate_audio_file

    def execute
      # Simulate processing delay
      sleep(rand(1..3))

      # Generate demo transcript based on language
      transcript = generate_demo_transcript
      call_recording.update!(transcript: transcript)

      { transcript: transcript }
    end

    private

    def generate_demo_transcript
      case call_recording.language
      when 'kyrgyz'
        kyrgyz_transcript
      when 'russian'
        russian_transcript
      when 'english'
        english_transcript
      else
        russian_transcript
      end
    end

    def kyrgyz_transcript
      <<~TRANSCRIPT
        Оператор: Салам алейкүм! Фитнес борборуна кош келиңиз. Менин атым #{random_operator_name}. Сизге кандай жардам бере алам?

        Кардар: Салам! Мен сиздердин фитнес борборуңуз жөнүндө угуп, кошумча маалымат алгым келет.

        Оператор: Албетте! Биз #{random_service} сунуштайбыз. Сиз кандай программага кызыкдарсыз?

        Кардар: Йога жана тренажер залы программалары жөнүндө билгим келет.

        Оператор: Мыкты тандоо! Биздин йога сабактар жума сайын #{random_day} жана #{random_day} күндөрү өтөт. Тренажер залы 24/7 ачык. Сизге #{random_price} сом туруктуу абонемент же #{random_price * 0.7} сом 3 айлык тандоо сунушталат.

        Кардар: Абдан кызыктуу! Акысыз сынап көрүү мүмкүндүгү барбы?

        Оператор: Ооба, албетте! Биз #{random_day} күнү саат #{random_time} же #{random_time} бош убакыт барбы? Сизге эң ыңгайлуу убакытты тандай аласыз.

        Кардар: #{random_day} күнү саат #{random_time} мага ылайыктуу болот.

        Оператор: Мыкты! Мен сизди #{random_day} күнү саат #{random_time} катталдым. Сиздин #{random_contact} телефонуңуз менен байланышып, эскертме жиберебиз.

        Кардар: Рахмат! Көрүшкөнчө.

        Оператор: Рахмат чоң! Сизди күтүп калабыз!
      TRANSCRIPT
    end

    def russian_transcript
      <<~TRANSCRIPT
        Оператор: Добрый день! Спасибо, что позвонили в фитнес-центр "#{random_company_name}". Меня зовут #{random_operator_name}. Чем могу помочь?

        Клиент: Здравствуйте! Я слышал о вашем фитнесе и хотел бы узнать подробнее о ваших услугах.

        Оператор: Конечно! Мы предлагаем #{random_service}. Какая программа вас интересует больше всего?

        Клиент: Меня интересуют йога и тренажерный зал.

        Оператор: Отличный выбор! Наши занятия йогой проходят #{random_schedule}. Тренажерный зал работает круглосуточно. Мы можем предложить вам абонемент #{random_membership} за #{random_price} рублей в месяц.

        Клиент: Звучит интересно. А есть ли возможность бесплатного пробного посещения?

        Оператор: Да, разумеется! Мы предоставляем #{random_trial}. Когда вам было бы удобно прийти? У нас есть свободные слоты #{random_day} в #{random_time} или #{random_time}.

        Клиент: #{random_day} в #{random_time} мне подходит.

        Оператор: Превосходно! Я записал вас на #{random_day} в #{random_time}. Оставьте, пожалуйста, ваш номер телефона, и мы отправим вам напоминание.

        Клиент: Спасибо большое!

        Оператор: Пожалуйста! Будем рады видеть вас в нашем центре. До встречи!
      TRANSCRIPT
    end

    def english_transcript
      <<~TRANSCRIPT
        Operator: Good afternoon! Thank you for calling #{random_company_name} Fitness Center. My name is #{random_operator_name}. How can I help you today?

        Customer: Hello! I heard about your fitness center and would like to learn more about your services.

        Operator: Of course! We offer #{random_service}. Which program interests you the most?

        Customer: I'm interested in yoga classes and gym access.

        Operator: Excellent choice! Our yoga classes are held #{random_schedule}. The gym is open 24/7. We can offer you a #{random_membership} membership for #{random_price} dollars per month.

        Customer: That sounds interesting. Do you have a free trial available?

        Operator: Yes, absolutely! We provide #{random_trial}. When would be convenient for you to visit? We have available slots on #{random_day} at #{random_time} or #{random_time}.

        Customer: #{random_day} at #{random_time} works for me.

        Operator: Perfect! I've scheduled you for #{random_day} at #{random_time}. Please provide your phone number, and we'll send you a reminder.

        Customer: Thank you so much!

        Operator: You're welcome! We look forward to seeing you at our center. See you soon!
      TRANSCRIPT
    end

    def random_operator_name
      names = ['Айгуль', 'Нурлан', 'Асель', 'Бекжан', 'Anna', 'Dmitry', 'Elena', 'John', 'Sarah']
      names.sample
    end

    def random_company_name
      ['Premium', 'Elite', 'ProFit', 'MaxGym', 'Active Life'].sample
    end

    def random_service
      [
        'групповые тренировки, персональные занятия, йогу, пилатес и тренажерный зал',
        'полный спектр фитнес-услуг: кардио-зона, силовые тренировки, групповые программы',
        'yoga, pilates, cardio zone, strength training, and personal coaching'
      ].sample
    end

    def random_schedule
      ['по понедельникам и средам', 'вторник и четверг', 'каждый день', 'on Mondays and Wednesdays', 'Tuesday and Thursday'].sample
    end

    def random_membership
      ['безлимитный', 'дневной', 'вечерний', 'unlimited', 'daytime', 'evening'].sample
    end

    def random_trial
      ['бесплатное пробное занятие', '3-дневный пробный период', 'одно бесплатное посещение', 'free trial session', '3-day trial period'].sample
    end

    def random_price
      [2500, 3500, 4500, 5500, 49, 69, 89, 99].sample
    end

    def random_day
      ['понедельник', 'вторник', 'среду', 'четверг', 'пятницу', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].sample
    end

    def random_time
      ['10:00', '12:00', '14:00', '16:00', '18:00', '19:00'].sample
    end

    def random_contact
      ['+996 555 123 456', '+7 777 555 4433', '+1 555 123 4567'].sample
    end

    def validate_audio_file
      unless call_recording.audio_file.attached?
        errors.add(:base, 'Audio file not attached')
      end
    end
  end
end
