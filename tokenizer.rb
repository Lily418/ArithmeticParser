require('./errors.rb')

Token = Struct.new(:type, :value)
Token_Rule = Struct.new(:type, :regex)

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
        raise LexerError.new, "Unexpected input" + @input
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
