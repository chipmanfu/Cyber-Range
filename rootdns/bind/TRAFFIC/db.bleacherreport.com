;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.bleacherreport.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.bleacherreport.com.
@	IN	MX	10	bleacherreport.com.
@	IN	A		151.101.193.5
mail	IN	A		151.101.193.5
www	IN	A		151.101.193.5
ns1	IN	A		198.41.0.4
