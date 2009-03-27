using GLib;

namespace Vala.Runtime.YAML {
	public class Parser {
		KeyStartFunc key_start;
		KeyStartFunc key_end;
	}

	public enum KeyType {
		SCALAR,
		MAP,
		LIST,
	}

	public class Key : Boxed {
		public KeyType type;
		public string key;
		public string anchor;
		public string alias;
		public string @value;
		public bool is_seq;
		public bool is_map;
		public bool is_scalar;
		public List<Key> children;
		public int ind;
		
		public string to_string() {
			StringBuilder sb = new StringBuilder("");
			for(int i = 0; i < ind; i++) {
				sb.append("  ");
			}
			sb.append(key);
			sb.append(" : ");
			if(@value != null) {
				sb.append(@value);
			}
			if(anchor != null) {
				sb.append_unichar('&');
				sb.append(anchor);
			}
			if(alias != null) {
				sb.append_unichar('*');
				sb.append(alias);
			}
			return sb.str;
		}
	}

	public class Context {
		private weak Parser parser;
		private string buffer;
		private weak string p;

		private unichar indicator;

		private Queue<unowned Key> stack = new Queue<unowned Key>();

		public List<Key> documents;

		private bool EOS = false;
		private const int TABSTOP = 4;
		public Context(Parser parser) {
			this.parser = parser;
		}
		public void add_string(string s) {
			buffer = s;
			p = buffer;
			EOS = false;
			parse();
		}
		private bool test_bod() {
			int n = skip_chars('-');
			if(n >= 3) {
				skip_chars('\n');
				return true;
			} else {
				rewind(n);
				return false;
			}
		}
		private bool test_eod() {
			int n = skip_chars('.');
			if(n >= 3) {
				skip_chars('\n');
				return true;
			} else {
				rewind(n);
				return false;
			}
		}
		private void parse_line() {
			Key k = new Key();
			bool in_seq = false;
			k.ind = skip_blanks();

			accept_indicator();
			switch(indicator) {
				case '-':
					skip_blanks();
					in_seq = true;
				break;
				case 0:
				break;
			}
			k.key = accept_string();
			skip_blanks();
			accept_colon();
			skip_blanks();
			accept_indicator();
			switch(indicator) {
				case '&':
					k.anchor = accept_string();
				break;
				case '*':
					k.alias = accept_string();
				break;
				case '|':
				break;
				case 0:
					skip_blanks();
					k.@value = accept_string();
					if(k.@value != null)
						k.is_scalar = true;
				break;
			}
			skip_blanks();
			skip_chars('\n');

			weak Key parent = pop_to_parent(k);
			if(in_seq) parent.is_seq = true;
			else parent.is_map = true;
			stack.push_tail(k);
			begin_key(k);
			parent.children.append(# k);
		}
		private weak Key pop_to_parent (Key k) {
			weak Key tail = stack.peek_tail();
			while(k.ind <= tail.ind) {
				weak Key finished_key = stack.pop_tail();
				finish_key(finished_key);
				tail = stack.peek_tail();
			}
			return tail;
		}
		private void begin_key(Key k){
			message("key start   : %s", k.to_string());
		}
		private void finish_key(Key k) {
			message("key finished: %s", k.to_string());
		}
		private void parse() {
			while(!EOS) {
				skip_chars('\n');
				bool eod = test_eod();
				bool bod = test_bod();
				if(bod) eod = true;
				if(eod) {
					weak Key k = null;
					while(null != (k = stack.pop_tail())) {
						finish_key(k);
					}
					message("eod");
				}
				if(bod || documents == null) {
					Key doc = new Key();
					doc.ind = -2;
					doc.key = "#doc";
					stack.push_tail(doc);
					documents.append(#doc);
					message("bod");
				}
				if(!EOS) parse_line();
			}
		}

		unichar get_char() {
			unichar c = p.get_char();
			if(c == 0) EOS = true;
			return c;
		}
		void next_char() {
			p = p.next_char();
		}

		void rewind(int n) {
			while(n > 0) {
				p = p.prev_char();
				n--;
			}
		}
		private bool accept_indicator() {
			unichar c = get_char();
			if(c == '|'
			|| c == '&'
			|| c == '*'
			|| c == '-') {
				indicator = c;
				next_char();
				return true;
			}
			indicator = 0;
			return false;
		}

		private bool accept_colon() {
			if(expect_char(':')) {
				next_char();
				return true;
			}
			return false;
		}

		private string accept_string() {
			unichar c;
			StringBuilder sb = new StringBuilder("");
			while( 0 != (c = get_char())) {
				if(c == ' ' || c == '\t' || c == ':' || c == '\n') {
					break;
				}
				sb.append_unichar(c);
				next_char();
			}
			return sb.str;
		}

		private bool expect_char(unichar ch) {
			unichar c = get_char();
			if(c == ch) return true;
			return false;
		}

		private int skip_blanks() {
			unichar c = get_char();
			int r = 0;
			while(c != 0) {
				switch(c) {
					case ' ':
						r++;
					break;
					case '\t':
						r+=TABSTOP;
					break;
					default:
					return r;
				}
				next_char();
				c = get_char();
			}
			return r;
		}

		private int skip_chars(unichar ch) {
			unichar c = get_char();
			int r = 0;
			while(c == ch) {
				next_char();
				c = get_char();
				r++;
			}
			return r;
		}
	}
	public delegate bool KeyStartFunc(Context pc, Key key);
	public delegate bool KeyEndFunc(Context pc, Key key);
}
