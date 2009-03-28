using GLib;

namespace Vala.Runtime.YAML {
	errordomain Error {
		MIXED_NODE_TYPE,
		EXPECT_INDICATOR,
		EXPECT_BLANK,
		UNEXPECTED_EOS,
		EXPECT_CHAR,
	}
	public class Parser : Boxed {
		public KeyStartFunc key_start;
		public KeyStartFunc key_end;
	}

	public enum KeyType {
		SCALAR,
		MAP,
		SEQ,
	}

	public class Key : Boxed {
		public KeyType type;
		public string key;
		public string anchor;
		public string alias;
		public string tag;
		public string @value;
		public bool is_seq;
		public bool is_map;
		public bool is_scalar;
		public List<Key> mapping;
		public List<Key> sequence;
		public int ind;
		
		public string to_string() {
			StringBuilder sb = new StringBuilder("");
			sb.append(key);
			sb.append(" : ");
			if(anchor != null) {
				sb.append_unichar('&');
				sb.append(anchor);
			}
			if(alias != null) {
				sb.append_unichar('*');
				sb.append(alias);
			}
			if(@value != null) {
				sb.append(@value);
			}
			return sb.str;
		}
		public string to_string_r() {
			StringBuilder sb = new StringBuilder("");
			for(int i = 0; i < ind; i++) {
				sb.append(" ");
			}
			if(key == "#doc") {
				sb.append("---");
				sb.append_unichar('\n');
			} else if (key == "#seq") {
				sb.append("- ");
			} else {
				sb.append(key);
				sb.append(" : ");
				if(anchor != null) {
					sb.append_unichar('&');
					sb.append(anchor);
				}
				if(alias != null) {
					sb.append_unichar('*');
					sb.append(alias);
				}
				if(@value != null) {
					if(@value.chr(-1, '\n') == null) {
						sb.append(@value);
					} else {
						sb.append(" | \n");
						string [] lines = @value.split("\n");
						foreach(string line in lines) {
							for(int i = 0; i < ind + 2; i++) {
								sb.append(" ");
							}
							sb.append(line);
							sb.append_unichar('\n');
						}
					}
				}
				sb.append_unichar('\n');
			}
			bool first = true;
			foreach(weak Key k in mapping) {
				if(first && key == "#seq") {
					sb.append(k.to_string_r().offset(ind + 2));
					first = false;
				} else
					sb.append(k.to_string_r());
			}
			foreach(weak Key k in sequence) {
				sb.append(k.to_string_r());
			}
			if(key == "#doc") {
				sb.append("...\n");
			}
			return sb.str;
		}
	}

	public class Context : Boxed {
		private weak Parser parser;
		private string buffer;
		private weak string p;

		private int position;
		private int line;

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
		private void accept_bod_line() {
			int n = skip_chars('-');
			string tag = null;
			bool bod = false;
			if(n >= 3) {
				tag = accept_tag();
				skip_chars('\n');
				bod = true ;
			} else {
				rewind(n);
				bod = false;
			}
			if(bod || documents == null) {
				weak Key k = null;
				/*First clean up the old document*/
				while(null != (k = stack.pop_tail())) {
					finish_key(k);
				}

				Key doc = new Key();
				doc.ind = -2;
				doc.key = "#doc";
				doc.tag = tag;
				stack.push_tail(doc);
				documents.append(#doc);
			}
		}
		private void accept_eod_line() {
			int n = skip_chars('.');
			if(n >= 3) {
				skip_chars('\n');
				weak Key k = null;
				while(null != (k = stack.pop_tail())) {
					finish_key(k);
				}
			} else {
				rewind(n);
			}
		}
		private void accept_key_line() {
			Key k = new Key();
			bool in_seq = false;
			k.ind = skip_blanks();
			message("ind = %d", k.ind);
			switch(accept_indicator()) {
				case '-':
					k.key = "#seq";
					int ind = k.ind; /*save ind since k will be transferred*/
					weak Key parent = pop_to_parent(k);
					stack.push_tail(k);
					parent.sequence.append(# k);
					parent.is_seq = true;
					k = new Key();
					int extra_ind = skip_blanks();
					k.ind = extra_ind + ind + 1;
				break;
				case 0:
				break;
				default:
					throw new Error.EXPECT_BLANK(
					"Expecting blank at %s".printf(location()));
				break;
			}

			k.key = accept_string();
			skip_blanks();
			switch(accept_indicator()) {
				case ':':
				break;
				default:
					throw new Error.EXPECT_INDICATOR(
					"Expecting ':' at %s".printf(location()));
				break;
			}
			skip_blanks();
			switch(accept_indicator()) {
				case '&':
					k.anchor = accept_string();
				break;
				case '*':
					k.alias = accept_string();
				break;
				case '!':
					rewind(1);
					k.tag = accept_tag();
				break;
				case '|':
					accept_until('\n');
					accept_char('\n');
					k.@value = accept_block_lines(k.ind, false);
				break;
				case '>':
					accept_until('\n');
					accept_char('\n');
					k.@value = accept_block_lines(k.ind, true);
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
			parent.is_map = true;
			stack.push_tail(k);
			begin_key(k);
			message("adding to parent %s", parent.key);
			parent.mapping.append(# k);
		}
		private string? accept_block_lines(int ind, bool folded) {
			int real_ind = -1;
			StringBuilder sb = new StringBuilder("");
			real_ind = skip_blanks();

			do {
				sb.append(accept_until('\n'));

				accept_char('\n');
				real_ind = skip_blanks();
				message("real = %d, ind = %d", real_ind, ind);
				if(real_ind <= ind) {
					rewind(real_ind);
					rewind(1); /* the new line*/
					message("rewinded");
					break;
				}

				if(!folded)
					sb.append_unichar('\n');
				else
					sb.append_unichar(' ');
					
				if(EOS) throw new Error.UNEXPECTED_EOS(
					"stream not supposed to break at %s".printf(location()));
			} while(true);
			return sb.str;
		}
		private string? accept_tag() {
			skip_blanks();
			if(accept_indicator() == '!') {
				return accept_until('\n');
			}
			return null;
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
			if(parser.key_start != null)
				parser.key_start(this, k);
		}
		private string location() {
			return "line %d char %d".printf(line, position);
		}
		private void finish_key(Key k) {
			if(k.is_map && k.is_seq) {
				throw new 
				Error.MIXED_NODE_TYPE(
				"Mixing mapping and sequence %s at %s".printf(k.key, location()));
			}
			if((k.is_scalar && k.is_map)
			|| (k.is_scalar && k.is_seq)) {
				throw new 
				Error.MIXED_NODE_TYPE(
				"Mixing scalar with mapping or sequence on %s at %s".printf(k.key, location()));
			}
			if(k.is_scalar) k.type = KeyType.SCALAR;
			if(k.is_map) k.type = KeyType.MAP;
			if(k.is_seq) k.type = KeyType.SEQ;

			if(parser.key_end != null)
				parser.key_end(this, k);

		}
		private void parse() {
			while(!EOS) {
				skip_chars('\n');
				accept_eod_line();
				accept_bod_line();
				if(!EOS) accept_key_line();
			}
		}

		unichar get_char() {
			unichar c = p.get_char();
			return c;
		}

		void next_char() {
			p = p.next_char();
			unichar c = get_char();
			if(c == 0) {
				EOS = true;
			} else {
				if(c == '\n') {
					line++;
					position = 0;
				} else {
					position++;
				}
			}
		}

		void rewind(int n) {
			while(n > 0) {
				p = p.prev_char();
				n--;
			}
		}
		private unichar accept_indicator() {
			unichar c = get_char();
			if(c == '|'
			|| c == '>'
			|| c == '#'
			|| c == '&'
			|| c == '*'
			|| c == '!'
			|| c == ':'
			|| c == '-') {
				next_char();
				return c;
			}
			return 0;
		}

		private string? accept_string() {
			unichar c;
			StringBuilder sb = new StringBuilder("");
			bool double_quoted = false;
			bool single_quoted = false;
			bool escaped = false;
			bool empty = true;
			bool quoted = false;
			while( 0 != (c = get_char())) {
				if(!double_quoted && !single_quoted
				&& (c == ':' || c == '\n')) {
					break;
				}
				if(single_quoted && c == '\'') {
					next_char();
					break;
				}
				if(double_quoted && !escaped && c == '"') {
					next_char();
					break;
				}
				if(double_quoted && !escaped && c == '\\') {
					escaped = true;
					next_char();
					continue;
				}
				if(double_quoted && escaped) {
					escaped = false;
					empty = false;
					sb.append_unichar(c);
					next_char();
					continue;
				}
				if(c == '\'') {
					single_quoted = true;
					quoted = true;
					next_char();
					continue;
				}
				if(c == '"') {
					quoted = true;
					double_quoted = true;
					next_char();
					continue;
				}
				empty = false;
				sb.append_unichar(c);
				next_char();
			}
			if(empty) return null;
			if(!quoted) sb.str.strip();
			return sb.str;
		}

		private string accept_until(unichar ch) {
			unichar c;
			StringBuilder sb = new StringBuilder("");
			while(ch != (c = get_char())) {
				sb.append_unichar(c);
				next_char();
			}
			return sb.str;
		}
		private int skip_blanks(int most = -1) {
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
				if(r >= most && most != -1) return r;
				next_char();
				c = get_char();
			}
			return r;
		}

		private void accept_char(unichar ch) {
			if(ch == get_char()) {
				next_char();
			} else
			throw new Error.EXPECT_CHAR(
			"Expecting '%C' at %s".printf(ch, location()));
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
