require('./errors')

Parse_Result = Struct.new(:symbol, :remaining_tokens)

def parse(symbol_to_parse, tokens, parser_table, terminals, nullables)

    if tokens.length == 0
        if nullables.include?(symbol_to_parse)
            return Parse_Result.new({type: symbol_to_parse, value: nil}, tokens)
        else
            raise ParserError.new, "Unexpected end of input"
        end
    end

    current_token_type = tokens[0].type

    if terminals.include? symbol_to_parse
        if current_token_type == symbol_to_parse
            return Parse_Result.new({type: symbol_to_parse, value: tokens[0].value}, tokens[1..-1])
        else
            raise ParserError.new, "Unexpected " + tokens[0].value
        end
    else

        rule = parser_table[current_token_type][symbol_to_parse]
        puts  "Parsing: " + symbol_to_parse.to_s +  " Current Token: " + tokens[0].value + " using rule " + symbol_to_parse.to_s + " ::= " + rule.to_s

        raise ParserError.new, "Unexpected " + tokens[0].value if rule == nil

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
