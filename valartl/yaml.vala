using GLib;

namespace Vala.Runtime.YAML {
	errordomain Error {
		MIXED_NODE_TYPE,
		EXPECT_INDICATOR,
		EXPECT_BLANK,
		UNEXPECTED_EOS,
		EXPECT_CHAR,
	}
	public enum NodeType {
		SCALAR,
		MAP,
		SEQ,
	}
	public class Parser {
		public NodeStartFunc node_start;
		public NodeEndFunc node_end;
		public Parser(NodeStartFunc? node_start = null, NodeEndFunc? node_end = null) {
			this.node_start = node_start;
			this.node_end = node_end;
		}
	}


	public class Node {
		public weak Node parent;
		public NodeType type;
		public string key;
		public string anchor;
		public string alias;
		public string tag;
		public string @value;
		public bool is_seq;
		public bool is_map;
		public bool is_scalar;
		public HashTable<unowned string, Node> mapping = new HashTable<unowned string, Node>(str_hash, str_equal);
		public List<Node> sequence;
		public List<unowned Node> mapping_list;
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
			bool seq_adjust = false;
			if(key== "#doc") {
				sb.append("---");
				sb.append_unichar('\n');
			} else if (key== "#seq") {
				for(int i = 0; i < ind - 1; i++) {
					sb.append(" ");
				}
				sb.append("- ");
				seq_adjust = true;
				if(anchor != null) {
					sb.append_unichar('&');
					sb.append(anchor);
					sb.append_unichar('\n');
					seq_adjust = false;
				}
				if(alias != null) {
					/*only an alias*/
					sb.append_unichar('*');
					sb.append(alias);
					sb.append_unichar('\n');
					seq_adjust = false;
				}
			} else {
				for(int i = 0; i < ind; i++) {
					sb.append(" ");
				}
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

			foreach(weak Node k in mapping_list) {
				if(seq_adjust && first) {
					sb.append(k.to_string_r().offset(ind + 1));
				} else 
					sb.append(k.to_string_r());
				first = false;
			}

			foreach(weak Node k in sequence) {
				sb.append(k.to_string_r());
			}
			if(key == "#doc") {
				sb.append("...\n");
			}
			return sb.str;
		}
	}

	public class Context {
		private Parser parser;
		private string buffer;
		private weak string p;

		private int position;
		private int line;

		private Queue<unowned Node> stack = new Queue<unowned Node>();

		public List<Node> documents;

		private bool EOS = false;
		private const int TABSTOP = 4;
		public Context(Parser parser) {
			this.parser = parser;
		}
		public void parse(string s) {
			buffer = s;
			p = buffer;
			EOS = false;
			while(!EOS) {
				skip_chars('\n');
				accept_eod_line();
				accept_bod_line();
				accept_comment_line();
				if(!EOS) accept_node_line();
			}
		}
		private void accept_comment_line() {
			switch(accept_indicator("#")){
				case '#':
				accept_until('\n');
				accept_char('\n');
				break;
			}
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
				weak Node k = null;
				/*First clean up the old document*/
				while(null != (k = stack.pop_tail())) {
					finish_node(k);
				}

				Node doc = new Node();
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
				weak Node k = null;
				while(null != (k = stack.pop_tail())) {
					finish_node(k);
				}
			} else {
				rewind(n);
			}
		}
		private void accept_node_line() {
			bool in_seq = false;
			int ind = skip_blanks();
			switch(accept_indicator("-")) {
				case '-':
					Node k = new Node();
					k.key = "#seq";
					/*To allow aligning - with the parent node*/
					k.ind = ++ind;
					k.parent = pop_to_parent(k);
					stack.push_tail(k);
					k.parent.is_seq = true;
					int extra_ind = skip_blanks();
					bool interrupted = false;
					switch(accept_indicator("*&")) {
						case '*':
							k.alias = accept_token();
							accept_until('\n');
							accept_char('\n');
						interrupted = true;
						break;
						case '&':
							k.anchor = accept_token();
							skip_blanks();
						break;
					}
					weak Node parent = k.parent;
					parent.sequence.append(# k);
					ind += extra_ind;
					if(interrupted) return;
				break;
			}

			Node k = new Node();
			k.ind = ind;
			k.key = accept_string();
			if(k.key == null) {
				/*ignore empty(introduced by - &anchor \n*/
				accept_until('\n');
				accept_char('\n');
				return;
			}
			skip_blanks();
			switch(accept_indicator(":")) {
				case ':':
				break;
				default:
					throw new Error.EXPECT_INDICATOR(
					"Expecting ':' at %s".printf(location()));
				break;
			}
			skip_blanks();
			switch(accept_indicator("&*!|>")) {
				case '&':
					k.anchor = accept_token();
				break;
				case '*':
					k.alias = accept_token();
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

			k.parent = pop_to_parent(k);
			k.parent.is_map = true;
			stack.push_tail(k);
			begin_node(k);
			weak string key = k.key;
			weak Node parent = k.parent;
			parent.mapping_list.append(k);
			parent.mapping.insert(key, #k);
		}
		private string? accept_block_lines(int ind, bool folded) {
			int real_ind = -1;
			StringBuilder sb = new StringBuilder("");
			real_ind = skip_blanks();

			do {
				sb.append(accept_until('\n'));

				accept_char('\n');
				real_ind = skip_blanks();
				if(real_ind <= ind) {
					rewind(real_ind);
					rewind(1); /* the new line*/
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
			if(accept_indicator("!") == '!') {
				return accept_until('\n');
			}
			return null;
		}
		private weak Node pop_to_parent (Node k) {
			weak Node tail = stack.peek_tail();
			while(k.ind <= tail.ind) {
				weak Node finished_node = stack.pop_tail();
				finish_node(finished_node);
				tail = stack.peek_tail();
			}
			return tail;
		}
		private void begin_node(Node k){
			if(parser.node_start != null)
				parser.node_start(this, k);
		}
		private string location() {
			return "line %d char %d".printf(line, position);
		}
		private void finish_node(Node k) {
			assert(k.key != null);
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
			if(k.is_scalar) k.type = NodeType.SCALAR;
			if(k.is_map) k.type = NodeType.MAP;
			if(k.is_seq) k.type = NodeType.SEQ;

			if(parser.node_end != null)
				parser.node_end(this, k);

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
		private unichar accept_indicator(string indicators) {
			unichar c = get_char();
			if(indicators.chr(-1, c)!= null) {
				next_char();
				return c;
			}
			return 0;
		}

		private string? accept_token() {
			StringBuilder sb = new StringBuilder("");
			unichar c;
			while( 0 != (c = get_char())) {
				if(c == ' '
				|| c == '\n')
					break;
				sb.append_unichar(c);
				next_char();
			}
			return sb.str;
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
	public delegate bool NodeStartFunc(Context pc, Node node);
	public delegate bool NodeEndFunc(Context pc, Node node);
}
