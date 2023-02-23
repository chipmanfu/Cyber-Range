$TTL 3600
@	IN	SOA	@	ns1.example.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.example.com.
@	IN	MX	10	example.com.
@	IN	A		1.2.3.4
mail	IN	A		1.2.3.4
www	IN	A		1.2.3.4
ns1	IN	A		198.41.0.4
