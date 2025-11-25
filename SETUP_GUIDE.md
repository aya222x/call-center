# 🚀 Руководство по запуску и использованию системы оценки KPI колл-центра

## 📋 Содержание
1. [Требования](#требования)
2. [Первоначальная настройка](#первоначальная-настройка)
3. [Демо-данные](#демо-данные)
4. [Тестирование через консоль](#тестирование-через-консоль)
5. [Настройка OpenAI](#настройка-openai)
6. [Тестирование AI функций](#тестирование-ai-функций)
7. [Запуск тестов](#запуск-тестов)
8. [Следующие шаги](#следующие-шаги)

---

## Требования

- Ruby 3.3.6
- Rails 8.0.2.1
- Node.js (для Vite)
- OpenAI API ключ (для транскрипции и оценки)

---

## Первоначальная настройка

### 1. Установка зависимостей

```bash
# Установка Ruby gems
bundle install

# Установка Node пакетов
npm install
```

### 2. Настройка базы данных

```bash
# Создание базы данных
bin/rails db:create

# Применение миграций
bin/rails db:migrate

# Создание демо-данных
bin/rails demo:setup
```

---

## Демо-данные

После выполнения `bin/rails demo:setup` в системе будут созданы:

### 🏢 Организационная структура
- **2 отдела**: Sales Department, Bank Department
- **2 команды**: Sales Team Alpha, Bank Support Team
- **2 скрипта звонков**: для продаж и поддержки

### 👥 Пользователи (все с паролем `password123`)

| Роль | Email | Доступ |
|------|-------|--------|
| **Администратор** | admin@example.com | Полный доступ ко всему |
| **Менеджер** | manager@example.com | Просмотр всех данных, отчёты |
| **Супервайзор 1** | supervisor1@example.com | Команда Sales Team Alpha |
| **Супервайзор 2** | supervisor2@example.com | Команда Bank Support Team |
| **Оператор 1** | operator1@example.com | Свои записи (Sales) |
| **Оператор 2** | operator2@example.com | Свои записи (Bank) |

### 📞 Примеры звонков
- **2 завершённых звонка** с оценками (90/100 и 80/100)
- **1 загруженный звонок** ожидает обработки

---

## Тестирование через консоль

### Запуск Rails консоли

```bash
bin/rails console
```

### Примеры команд

#### 1. Просмотр всех записей

```ruby
# Все записи звонков
CallRecording.all

# Записи с оценками
CallRecording.completed.includes(:evaluation)

# Записи конкретного оператора
operator = User.find_by(email: 'operator1@example.com')
operator.call_recordings
```

#### 2. Просмотр оценок

```ruby
# Все оценки
Evaluation.all

# Лучшие оценки
Evaluation.order(overall_score: :desc).limit(5)

# Оценка с детальной информацией
eval = Evaluation.first
puts "Overall Score: #{eval.overall_score}"
puts "Script Adherence: #{eval.script_adherence_score}"
puts "Politeness: #{eval.politeness_score}"
puts "Speed: #{eval.resolution_speed_score}"
puts "Terminology: #{eval.terminology_score}"
puts "Success: #{eval.success_score}"
puts "\nRecommendations:"
puts eval.recommendations
```

#### 3. Проверка авторизации

```ruby
# Проверка политик доступа
admin = User.find_by(email: 'admin@example.com')
operator = User.find_by(email: 'operator1@example.com')
recording = CallRecording.first

# Может ли администратор видеть запись?
DepartmentPolicy.new(admin, Department).index?  # => true

# Может ли оператор видеть чужую запись?
CallRecordingPolicy.new(operator, recording).show?  # зависит от owner
```

#### 4. Статистика

```ruby
# Общая статистика
puts "Departments: #{Department.count}"
puts "Teams: #{Team.count}"
puts "Total Users: #{User.count}"
puts "  - Admins: #{User.admin.count}"
puts "  - Managers: #{User.manager.count}"
puts "  - Supervisors: #{User.supervisor.count}"
puts "  - Operators: #{User.operator.count}"
puts "Call Recordings: #{CallRecording.count}"
puts "  - Completed: #{CallRecording.completed.count}"
puts "  - Pending: #{CallRecording.uploaded.count}"
puts "Evaluations: #{Evaluation.count}"
puts "Average Score: #{Evaluation.average(:overall_score).to_f.round(2)}"
```

#### 5. Создание новой записи звонка

```ruby
# Найти оператора и скрипт
operator = User.find_by(email: 'operator1@example.com')
script = CallScript.find_by(call_type: :sales)

# Создать запись
recording = CallRecording.create!(
  user: operator,
  call_script: script,
  status: :uploaded,
  language: :russian,
  call_date: Date.current,
  duration_seconds: 150,
  customer_name: 'Test Customer',
  customer_phone: '+996555111222'
)

puts "Created recording ##{recording.id}"
```

---

## Настройка OpenAI

### 1. Получение API ключа

1. Зарегистрируйтесь на https://platform.openai.com
2. Создайте API ключ в разделе API Keys
3. Пополните баланс (минимум $5)

### 2. Установка ключа

```bash
# Создайте файл .env в корне проекта
echo "OPENAI_API_KEY=your_api_key_here" > .env

# Или экспортируйте переменную окружения
export OPENAI_API_KEY='your_api_key_here'
```

---

## Тестирование AI функций

⚠️ **Внимание**: Следующие команды используют реальный OpenAI API и списывают деньги с вашего баланса!

### 1. Тестирование транскрипции (Whisper)

```ruby
# В Rails консоли
recording = CallRecording.uploaded.first

# ВАЖНО: Нужен реальный аудиофайл!
# Прикрепите аудио файл к записи:
recording.audio_file.attach(
  io: File.open('/path/to/your/audio.mp3'),
  filename: 'call.mp3',
  content_type: 'audio/mpeg'
)

# Запустить транскрипцию
result = Openai::TranscribeAudio.run(call_recording: recording)

if result.valid?
  puts "✅ Транскрипция успешна!"
  puts "Текст: #{result.result[:transcript]}"
  puts "Статус записи: #{recording.reload.status}"
else
  puts "❌ Ошибка: #{result.errors.full_messages}"
end
```

### 2. Тестирование оценки (GPT-4)

```ruby
# В Rails консоли
# Найти запись с транскрипцией
recording = CallRecording.find_by(status: :analyzing)

# Если нет, создать тестовую
recording = CallRecording.create!(
  user: User.operator.first,
  call_script: CallScript.first,
  status: :analyzing,
  language: :russian,
  call_date: Date.current,
  duration_seconds: 180,
  transcript: "Оператор: Добрый день! Клиент: Здравствуйте. Оператор: Чем могу помочь?"
)

# Запустить оценку
result = Openai::EvaluateCall.run(call_recording: recording)

if result.valid?
  eval = result.result[:evaluation]
  puts "✅ Оценка успешна!"
  puts "Общий балл: #{eval.overall_score}/100"
  puts "Следование скрипту: #{eval.script_adherence_score}"
  puts "Вежливость: #{eval.politeness_score}"
  puts "Скорость: #{eval.resolution_speed_score}"
  puts "Терминология: #{eval.terminology_score}"
  puts "Успешность: #{eval.success_score}"
  puts "\nРекомендации:"
  puts eval.recommendations
else
  puts "❌ Ошибка: #{result.errors.full_messages}"
end
```

### 3. Полный цикл обработки

```ruby
# Создать запись с аудио → транскрибировать → оценить
recording = CallRecording.create!(
  user: User.operator.first,
  call_script: CallScript.sales.first,
  status: :uploaded,
  language: :russian,
  call_date: Date.current,
  duration_seconds: 0
)

# Прикрепить аудио (замените на свой путь)
recording.audio_file.attach(
  io: File.open('/path/to/call.mp3'),
  filename: 'call.mp3',
  content_type: 'audio/mpeg'
)

# Шаг 1: Транскрипция
puts "📝 Транскрибирую..."
transcribe_result = Openai::TranscribeAudio.run(call_recording: recording)

if transcribe_result.valid?
  puts "✅ Транскрипция готова"
  recording.reload
  recording.update!(status: :analyzing)

  # Шаг 2: Оценка
  puts "🤖 Оцениваю..."
  evaluate_result = Openai::EvaluateCall.run(call_recording: recording)

  if evaluate_result.valid?
    puts "✅ Оценка готова"
    eval = evaluate_result.result[:evaluation]
    puts "Финальный балл: #{eval.overall_score}/100 (#{eval.score_label})"
  else
    puts "❌ Ошибка оценки: #{evaluate_result.errors.full_messages}"
  end
else
  puts "❌ Ошибка транскрипции: #{transcribe_result.errors.full_messages}"
end
```

---

## Запуск тестов

### Все тесты (175 specs)

```bash
bundle exec rspec
```

### Тесты по категориям

```bash
# Только модели (88 specs)
bundle exec rspec spec/models/

# Только политики (51 specs)
bundle exec rspec spec/policies/

# Только сервисы (36 specs)
bundle exec rspec spec/services/
```

### Отдельные файлы

```bash
# Тесты Department
bundle exec rspec spec/models/department_spec.rb

# Тесты OpenAI транскрипции
bundle exec rspec spec/services/openai/transcribe_audio_spec.rb
```

---

## Следующие шаги

### ✅ Что готово (Backend)
- ✅ База данных (6 таблиц)
- ✅ Модели с валидациями
- ✅ Авторизация (Pundit policies)
- ✅ OpenAI интеграция (транскрипция + оценка)
- ✅ 175 тестов (все зелёные)

### 🚧 Что нужно добавить (Frontend)

#### 1. Контроллеры
- Departments controller
- Call Scripts controller
- Call Recordings controller (с upload)
- Dashboard controller
- Evaluations controller

#### 2. React страницы
- Login page
- Dashboard (статистика)
- Call Recordings list/upload
- Call Scripts management (admin)
- Evaluation details page
- Reports page

#### 3. E2E тесты
- User authentication flow
- Call upload workflow
- Evaluation viewing
- Reports generation

---

## 💡 Полезные команды

```bash
# Запуск Rails сервера
bin/rails server

# Запуск Vite dev server
bin/vite dev

# Очистка базы и пересоздание демо-данных
bin/rails db:reset && bin/rails demo:setup

# Проверка маршрутов
bin/rails routes | grep call_recordings

# Запуск Rails консоли
bin/rails console

# Проверка Rubocop
bundle exec rubocop

# Применить миграции
bin/rails db:migrate

# Откатить последнюю миграцию
bin/rails db:rollback
```

---

## 📞 Поддержка

Если возникли вопросы:
1. Проверьте логи: `tail -f log/development.log`
2. Проверьте тесты: `bundle exec rspec`
3. Прочитайте PRODUCT_SPEC.md для деталей системы

---

## 🎯 Стоимость использования OpenAI

**Примерные расценки (на январь 2025):**

- **Whisper (транскрипция)**: $0.006 за минуту аудио
  - 5-минутный звонок ≈ $0.03

- **GPT-4 (оценка)**: ~$0.03-0.06 за оценку
  - Зависит от длины транскрипта

**Итого на 1 звонок**: ~$0.05-0.10

**Для 100 звонков в день**: ~$5-10 в день

---

*Система готова к тестированию бэкенда. Для полноценной работы требуется добавление UI (контроллеры + React страницы).*
