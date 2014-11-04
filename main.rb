require('./expressions')

puts "Enter arithmetic expression."
input = gets.chomp
puts Expressions.interpret(input)
