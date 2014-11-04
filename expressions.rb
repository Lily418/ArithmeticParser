require('./tokenizer.rb')
require('./parser')

module Expressions
    @@token_rules = []
    @@token_rules << Token_Rule.new(:OPENPAREN, /\(/)
    @@token_rules << Token_Rule.new(:CLOSEPAREN, /\)/)
    @@token_rules << Token_Rule.new(:PLUSOP, /\+/)
    @@token_rules << Token_Rule.new(:MULOP, /\*/)
    @@token_rules << Token_Rule.new(:NUMBER, /[0-9]+/)
    @@token_rules << Token_Rule.new(:WHITESPACE, /\s+/)

    #I could implement validation methods for the contents of the parse_table to make sure all symbols correspond to terminals/non-terminals as appropriate.
    @@parser_table = {}
    @@parser_table[:OPENPAREN]  = {E: [:T, :EPRIME], T: [:F, :TPRIME], F: [:OPENPAREN, :E, :CLOSEPAREN]}
    @@parser_table[:NUMBER]     = {E: [:T, :EPRIME], T: [:F, :TPRIME], F: [:NUMBER]}
    @@parser_table[:CLOSEPAREN] = {EPRIME: [], TPRIME: []}
    @@parser_table[:PLUSOP]     = {EPRIME: [:PLUSOP, :T, :EPRIME], TPRIME: []}
    @@parser_table[:MULOP]      = {TPRIME: [:MULOP, :F, :TPRIME]}

    @@nullables = [:TPRIME, :EPRIME]

    @@terminals = @@token_rules.map do |rule|
        rule.type
    end


    def self.evaluate(parse_tree)
        case parse_tree[:type]
        when :E
            t = evaluate(parse_tree[:value][0])
            eprime = evaluate(parse_tree[:value][1])
            return t + eprime
        when :T
            f = evaluate(parse_tree[:value][0])
            tprime = evaluate(parse_tree[:value][1])
            return f * tprime
        when :F
            return evaluate(parse_tree[:value][0])
        when :TPRIME
            if parse_tree[:value].nil?
                return 1
            end
            f = evaluate(parse_tree[:value][1])
            tprime = evaluate(parse_tree[:value][2])
            return f * tprime
        when :EPRIME
            if parse_tree[:value].nil?
                return 0
            end
            t = evaluate(parse_tree[:value][1])
            eprime = evaluate(parse_tree[:value][2])
            return t + eprime
        when :NUMBER
            return parse_tree[:value].to_i
        else
            raise "I don't know how to evaluate " + parse_tree[:type].to_s
        end
    end

    def self.interpret(expression_string)
        tokens = Tokenizer.new(@@token_rules, expression_string).tokens().select { |token| token.type != :WHITESPACE}
        parse_tree = parse(:E, tokens, @@parser_table, @@terminals, @@nullables).symbol
        puts parse_tree
        return evaluate(parse_tree)
    end
end
