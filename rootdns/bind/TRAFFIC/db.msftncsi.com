; Simulates Microsft online connection test site
$TTL	86400
@	IN	SOA	@	ns1.msftncsi.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.msftncsi.com.
@	IN	A		180.1.1.150	
www	IN	A	 	180.1.1.150	
ns1	IN	A		198.41.0.4
