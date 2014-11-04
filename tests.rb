require('./expressions')
require('./errors.rb')

test = Struct.new(:expression, :value)
tests = []

# Positive Tests
tests << test.new("5", 5)
tests << test.new("(5)", 5)
tests << test.new("(5 + 7)", 12)
tests << test.new("5 + 7", 12)
tests << test.new("2 * 5", 10)
tests << test.new("(2 * 5)", 10)
tests << test.new("1 + (2 * 5)", 11)
tests << test.new("1 + 2 + (2 * 5)", 13)
tests << test.new("1 + 2 * 3", 7)
tests << test.new("(1 + 2) * 3", 9)
tests << test.new("(1 + 2) * 3 * 2", 18)
tests << test.new("(100+ 1)", 101)

# Lexer Error
tests << test.new("5-5", LexerError)
tests << test.new("LexerError", LexerError)

# Parser Error
tests << test.new("()", ParserError)
tests << test.new("(", ParserError)
tests << test.new("5++4", ParserError)
tests << test.new("+4", ParserError)
tests << test.new("5*", ParserError)
tests << test.new(")(", ParserError)
tests << test.new("(5+5)*", ParserError)

tests.each do | test |
    begin
        result = Expressions.interpret(test.expression)
    rescue LexerError, ParserError => e
        result = e.class
    end


    if  result == test.value
        puts "Passed: " + test.expression + " == " + test.value.to_s
    else
        raise "FAIL: " + test.expression + " != " +  test.value.to_s
    end
end
