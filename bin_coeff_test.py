


def coeff(n,k):    
    k = min(k, n - k)

    if k == 0:
        return 1

    factors = range(n-k+1, n+1)

    for i in range(k, 0, -1):
        x = n - (n % i)
        factors[x - (n - k + 1)] /= i

    return reduce(lambda x, y: x*y, factors)


def wiki_coeff(n, k):
    if k < 0 or k > n:
        return 0
    if k == 0 or k == n:
        return 1
    k = min(k, n - k) # take advantage of symmetry
    c = 1
    for i in range(k):
        #print  "wiki",(n - i) ,i+1,float(n - i) / float(i + 1), (n-i) / (i+1) 
        #print "c before", c,
        c = c * (n - i) / (i + 1)
        #print "c after", c
    return c

for i in range(1,20):
    for j in range(0, i+1):
        print coeff(i,j) - wiki_coeff(i,j),
        if coeff(i,j) - wiki_coeff(i,j) != 0:
            print "ERR",i,j, coeff(i,j), wiki_coeff(i,j) 
    print


print wiki_coeff(7,3)
