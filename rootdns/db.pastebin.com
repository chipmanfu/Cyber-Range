$TTL 3600
@	IN	SOA	@	ns1.pastebin.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.pastebin.com.
@	IN	MX	10	pastebin.com.
@	IN	A		104.20.68.143
mail	IN	A		104.20.68.143
www	IN	A		104.20.68.143
ns1	IN	A		198.41.0.4
