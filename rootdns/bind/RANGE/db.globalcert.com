$TTL 3600
@	IN	SOA	@	ns1.globalcert.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.globalcert.com.
@	IN	MX	10	globalcert.com.
@	IN	A		180.1.1.50
mail	IN	A		180.1.1.50
www	IN	A		180.1.1.50
ns1	IN	A		198.41.0.4
