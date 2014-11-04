Token = Struct.new(:type, :value)
Token_Rule = Struct.new(:type, :regex)

token_rules = []
token_rules << Token_Rule.new(:OPENPAREN, /\(/)
token_rules << Token_Rule.new(:CLOSEPAREN, /\)/)
token_rules << Token_Rule.new(:PLUSOP, /\+/)
token_rules << Token_Rule.new(:MULOP, /\*/)
token_rules << Token_Rule.new(:NUMBER, /[0-9]+/)
token_rules << Token_Rule.new(:WHITESPACE, /\s+/)

class Tokenizer

    def initialize(token_rules, input)
        @token_rules = token_rules
        @input = input
    end

    def next_token()
        @token_rules.each do |rule|
            #Modify the rule to only match at the start of the string
            regex = Regexp.new(/\A/.source + rule.regex.source)
            match = regex.match @input
            unless match.nil?
                @input = @input[match[0].length.. -1]
                return Token.new(rule.type, match[0])
            end
        end
        raise "Unexpected input" + @input
    end

    def tokens()
        tokens = []
        until @input == ""
            t = next_token()
            tokens << t
        end
        return tokens
    end
end

puts "Enter arithmetic expression."
input = gets.chomp

tokens = Tokenizer.new(token_rules, input).tokens().select { |token| token.type != :WHITESPACE}

#I could implement validation methods for the contents of the parse_table to make sure all symbols correspond to terminals/non-terminals as appropriate.
parser_table = {}
parser_table[:OPENPAREN]  = {E: [:T, :EPRIME], T: [:F, :TPRIME], F: [:OPENPAREN, :E, :CLOSEPAREN]}
parser_table[:NUMBER]     = {E: [:T, :EPRIME], T: [:F, :TPRIME], F: [:NUMBER]}
parser_table[:CLOSEPAREN] = {EPRIME: [], TPRIME: []}
parser_table[:PLUSOP]     = {EPRIME: [:PLUSOP, :T, :EPRIME], TPRIME: []}
parser_table[:MULOP]      = {TPRIME: [:MULOP, :F, :TPRIME]}

nullables = [:TPRIME, :EPRIME]

terminals = token_rules.map do |rule|
    rule.type
end

Parse_Result = Struct.new(:symbol, :remaining_tokens)

def symbol_list_to_string symbol_list
    s = ""
    symbol_list.each do | symbol |
        s += symbol.value
    end
    return s
end

def parse(symbol_to_parse, tokens, parser_table, terminals, nullables)

    if tokens.length == 0
        if nullables.include?(symbol_to_parse)
            return Parse_Result.new({type: symbol_to_parse, value: nil}, tokens)
        else
            raise "Unexpected end of input"
        end
    end

    current_token_type = tokens[0].type

    if terminals.include? symbol_to_parse
        if current_token_type == symbol_to_parse
            return Parse_Result.new({type: symbol_to_parse, value: tokens[0].value}, tokens[1..-1])
        else
            raise "Unexpected " + tokens[0].value
        end
    else

        rule = parser_table[current_token_type][symbol_to_parse]
        puts  "Parsing: " + symbol_to_parse.to_s +  " Current Token: " + tokens[0].value + " using rule " + symbol_to_parse.to_s + " ::= " + rule.to_s


        return Parse_Result.new({type: symbol_to_parse, value: nil}, tokens) if rule == []

        parsed_symbols = []
        rule.each do | symbol |
            parse_result = parse(symbol, tokens, parser_table, terminals, nullables)
            # Remove parentheses nodes from expression
            parse_result[0][:value] = [parse_result[0][:value][1]] if parse_result[0][:type] == :F && parse_result[0][:value][0][:type] == :OPENPAREN
            tokens = parse_result.remaining_tokens
            parsed_symbols << parse_result.symbol
        end

        return Parse_Result.new({type: symbol_to_parse, value:parsed_symbols}, tokens)
    end

end

p parse_tree = parse(:E, tokens, parser_table, terminals, nullables)[0]

def evaluate(parse_tree)
    puts ""
    puts parse_tree

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
        puts "PARSE YO" + parse_tree.to_s
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

p evaluate(parse_tree)
