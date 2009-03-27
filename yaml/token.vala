namespace Vala.Runtime.YAML {
	private enum TokenType {
		SPACE,
		INDICATOR,
		LINE_BREAK,
		LITERAL,
	}
	private class Token {
		public TokenType type;
		public string token;
	}
	private class TokenReader {
		private enum State {
			NORMAL,
			SPACE,
			INDICATOR,
			LINE_BREAK,
			QUOTED_MIN, /*don't use*/
			PIPE_QUOTED,
			LESS_QUOTED,
			QUOTE_QUOTED,
			DQUOTE_QUOTED,
		}
		private weak string pointer;
		private State state = State.NORMAL;
		StringBuilder sb = new StringBuilder("");
		private TokenReader() {
			state = State.NORMAL;
		}
		private void expect_unichar(unichar c) {
			while(pointer[0] != 0 && pointer[0] != c) {
				pointer = pointer.next_char();
			}
		}
		private bool is_quoted() {
			if(state < State.QUOTED_MIN) {
				return true;
			}
			return false;
		}
		private bool is_indicator(unichar c) {
			switch(c) {
				case '|':
				case '<':
				case '*':
				case '&':
				case '-':
				case '"':
				case ''':
				case ':':
				return true;
			}
			return false;
		}
		private Token next_token() {
			weak string p = pointer;
			Token token = new Token();
			sb.truncate(0);
			while(p[0] != 0) {
				unichar c = p[0];
				switch(state) {
					case State.PIPE_QUOTED:
				}
				switch(c) {
					case ' ':
					
				}
				p = p.next_char();
			}
			return token;
		}
		
	}
}
