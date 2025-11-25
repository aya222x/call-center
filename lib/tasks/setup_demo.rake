namespace :demo do
  desc "Setup demo data for call center KPI system"
  task setup: :environment do
    puts "🚀 Creating demo data for Call Center KPI System..."

    # Create departments
    puts "\n📁 Creating departments..."
    sales_dept = Department.find_or_create_by!(name: 'Sales Department')
    bank_dept = Department.find_or_create_by!(name: 'Bank Department')
    puts "   ✅ Created: #{sales_dept.name}"
    puts "   ✅ Created: #{bank_dept.name}"

    # Create call scripts
    puts "\n📝 Creating call scripts..."
    sales_script = CallScript.find_or_create_by!(
      name: 'Outbound Sales Script',
      department: sales_dept
    ) do |script|
      script.call_type = :sales
      script.content = <<~SCRIPT
        1. Greet the customer warmly: "Good day! Thank you for your interest."
        2. Introduce yourself and the company
        3. Ask about their needs: "How can I help you today?"
        4. Present the product/service benefits
        5. Handle objections professionally
        6. Close the sale: "Would you like to proceed with the order?"
        7. Thank the customer: "Thank you for choosing us!"
      SCRIPT
    end
    puts "   ✅ Created: #{sales_script.name}"

    support_script = CallScript.find_or_create_by!(
      name: 'Customer Support Script',
      department: bank_dept
    ) do |script|
      script.call_type = :support
      script.content = <<~SCRIPT
        1. Greet professionally: "Hello, thank you for contacting our support."
        2. Ask for account information
        3. Listen to the issue carefully
        4. Acknowledge their concern: "I understand your situation."
        5. Provide step-by-step solution
        6. Confirm resolution: "Does this solve your issue?"
        7. Thank them: "Thank you for your patience."
      SCRIPT
    end
    puts "   ✅ Created: #{support_script.name}"

    # Create admin user
    puts "\n👤 Creating admin user..."
    admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
      user.name = 'System Admin'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = :admin
      user.admin = true
    end
    puts "   ✅ Admin: #{admin.email} / password123"

    # Create manager
    puts "\n👔 Creating manager..."
    manager = User.find_or_create_by!(email: 'manager@example.com') do |user|
      user.name = 'John Manager'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = :manager
    end
    puts "   ✅ Manager: #{manager.email} / password123"

    # Create teams with supervisors
    puts "\n👥 Creating teams..."

    supervisor1 = User.find_or_create_by!(email: 'supervisor1@example.com') do |user|
      user.name = 'Alice Supervisor'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = :supervisor
    end

    sales_team = Team.find_or_create_by!(
      name: 'Sales Team Alpha',
      department: sales_dept
    ) do |team|
      team.supervisor = supervisor1
    end
    supervisor1.update!(team: sales_team)
    puts "   ✅ Created: #{sales_team.name} (Supervisor: #{supervisor1.name})"

    supervisor2 = User.find_or_create_by!(email: 'supervisor2@example.com') do |user|
      user.name = 'Bob Supervisor'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = :supervisor
    end

    bank_team = Team.find_or_create_by!(
      name: 'Bank Support Team',
      department: bank_dept
    ) do |team|
      team.supervisor = supervisor2
    end
    supervisor2.update!(team: bank_team)
    puts "   ✅ Created: #{bank_team.name} (Supervisor: #{supervisor2.name})"

    # Create operators
    puts "\n🎧 Creating operators..."
    operator1 = User.find_or_create_by!(email: 'operator1@example.com') do |user|
      user.name = 'Maria Operator'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = :operator
      user.team = sales_team
    end
    puts "   ✅ Operator: #{operator1.name} (#{sales_team.name})"

    operator2 = User.find_or_create_by!(email: 'operator2@example.com') do |user|
      user.name = 'Aibek Operator'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = :operator
      user.team = bank_team
    end
    puts "   ✅ Operator: #{operator2.name} (#{bank_team.name})"

    # Create sample call recordings
    puts "\n📞 Creating sample call recordings..."

    recording1 = CallRecording.find_or_create_by!(
      user: operator1,
      call_script: sales_script,
      call_date: Date.current
    ) do |rec|
      rec.status = :completed
      rec.language = :russian
      rec.duration_seconds = 245
      rec.customer_name = 'Ivan Petrov'
      rec.customer_phone = '+996555123456'
      rec.transcript = <<~TRANSCRIPT
        Оператор: Добрый день! Спасибо за ваш интерес к нашему продукту. Меня зовут Мария, я представляю компанию XYZ.
        Клиент: Здравствуйте.
        Оператор: Чем я могу вам помочь сегодня?
        Клиент: Я хотел бы узнать о ваших тарифах на интернет.
        Оператор: Конечно! У нас есть несколько отличных предложений. Для домашнего использования у нас есть тарифы от 500 сомов в месяц.
        Клиент: Это интересно. А скорость какая?
        Оператор: До 100 Мбит/с. Также у нас есть акция - первый месяц бесплатно!
        Клиент: Отлично, я готов подключиться.
        Оператор: Замечательно! Спасибо, что выбрали нашу компанию!
      TRANSCRIPT
    end
    puts "   ✅ Recording 1: #{operator1.name} - Sales call (Russian)"

    # Create evaluation for recording1
    Evaluation.find_or_create_by!(call_recording: recording1) do |eval|
      eval.script_adherence_score = 85
      eval.politeness_score = 92
      eval.resolution_speed_score = 88
      eval.terminology_score = 90
      eval.success_score = 95
      eval.overall_score = 90
      eval.recommendations = "Excellent performance! The operator followed the script well, was very polite, and successfully closed the sale. Minor improvement: could provide more details about installation process."
    end
    puts "   ✅ Evaluation 1: Overall score 90/100 (Excellent)"

    recording2 = CallRecording.find_or_create_by!(
      user: operator2,
      call_script: support_script,
      call_date: Date.current - 1.day
    ) do |rec|
      rec.status = :completed
      rec.language = :kyrgyz
      rec.duration_seconds = 180
      rec.customer_name = 'Ainura Bekova'
      rec.customer_phone = '+996700987654'
      rec.transcript = <<~TRANSCRIPT
        Оператор: Саламатсызбы! Колдоого чалганыңызга рахмат.
        Клиент: Салам. Менин эсебимде маселе бар.
        Оператор: Кандай маселе?
        Клиент: Акча которгон, бирок келген жок.
        Оператор: Түшүнүктүү. Эсеп номериңизди айтсаңыз болот?
        Клиент: 1234567890
        Оператор: Рахмат. Азыр текшерип көрөм... Ооба, көрдүм. Акча 2 саат ичинде келет.
        Клиент: Рахмат!
        Оператор: Чыдамкайлыгыңызга рахмат!
      TRANSCRIPT
    end
    puts "   ✅ Recording 2: #{operator2.name} - Support call (Kyrgyz)"

    # Create evaluation for recording2
    Evaluation.find_or_create_by!(call_recording: recording2) do |eval|
      eval.script_adherence_score = 75
      eval.politeness_score = 88
      eval.resolution_speed_score = 82
      eval.terminology_score = 70
      eval.success_score = 85
      eval.overall_score = 80
      eval.recommendations = "Good performance overall. The operator was polite and resolved the issue. Areas for improvement: follow the script more closely, use more technical terminology when explaining the solution."
    end
    puts "   ✅ Evaluation 2: Overall score 80/100 (Good)"

    # Create one more recording without evaluation (uploaded status)
    recording3 = CallRecording.find_or_create_by!(
      user: operator1,
      call_script: sales_script,
      call_date: Date.current
    ) do |rec|
      rec.status = :uploaded
      rec.language = :english
      rec.duration_seconds = 0
      rec.customer_name = 'Test Customer'
      rec.customer_phone = '+996555000000'
    end
    puts "   ✅ Recording 3: #{operator1.name} - Pending processing"

    puts "\n" + "="*60
    puts "✅ Demo data setup complete!"
    puts "="*60

    puts "\n📊 Summary:"
    puts "   Departments: #{Department.count}"
    puts "   Teams: #{Team.count}"
    puts "   Users: #{User.count} (1 admin, 1 manager, 2 supervisors, 2 operators)"
    puts "   Call Scripts: #{CallScript.count}"
    puts "   Call Recordings: #{CallRecording.count}"
    puts "   Evaluations: #{Evaluation.count}"

    puts "\n🔑 Login credentials:"
    puts "   Admin:      admin@example.com / password123"
    puts "   Manager:    manager@example.com / password123"
    puts "   Supervisor: supervisor1@example.com / password123"
    puts "   Supervisor: supervisor2@example.com / password123"
    puts "   Operator:   operator1@example.com / password123"
    puts "   Operator:   operator2@example.com / password123"

    puts "\n💡 Next steps:"
    puts "   1. rails console - to test the system"
    puts "   2. Test OpenAI services (requires OPENAI_API_KEY)"
    puts "   3. Build frontend UI to complete the application"
  end
end
