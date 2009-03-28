using Vala.Runtime.YAML;

public int main() {
	Parser p = new Parser();
	p.key_start = (obj, key) => {
		message("key started : %s", key.key);
	};
	p.key_end = (obj, key) => {
		message("key ended   : %s", key.key);
	};
	Context c = new Context(p);
	
	c.add_string(
"""
--- !clarkevans.com/^invoice
invoice: 34843
date   : 2001-01-23
bill-to: &id001
    given  : Chris
    family : Dumars
    address:
        lines: |
            458 Walkman Dr.
            Suite #292
        city    : Royal Oak
        state   : MI
        postal  : 48046
ship-to: *id001
product:
    - sku         : BL394D
      quantity    : 4
      description : Basketball
      price       : 450.00
    - sku         : BL4438H
      quantity    : 1
      description : Super Hoop
      price       : 2392.00
tax  : 251.42
total: 4443.52
comments: >
    Late afternoon is best.
    Backup contact is Nancy
    Billsmer @ 338-4338.
...
""");
	foreach(weak Key k in c.documents) {
		message("%s", k.to_string_r());
	}
	return 0;
}
