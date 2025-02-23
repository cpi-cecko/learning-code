#
# Brute-force solution
#
def cut_rod(p, n):
    if n == 0:
        return 0
    best = float("-inf")
    for i in range(0, n):
        best = max(best, p[i] + cut_rod(p, n-i-1))
    return best

#
# Dynamic programming solution using memoization
#
def cut_rod_memoized(p, n):
    r = [float("-inf")] * (n+1)
    p.insert(0,0)
    return cut_rod_memoized_aux(p, n, r)

def cut_rod_memoized_aux(p, n, r):
    if r[n] >= 0:
        return r[n]

    best = float("-inf")
    if n == 0:
        best = 0
    else:
        for i in range(1, n+1):
            best = max(best, p[i] + cut_rod_memoized_aux(p, n-i, r))

    r[n] = best

    return best

#
# Memoized cut-rod returning solution
#
def cut_rod_memoized_extended(p, n):
    r = [float("-inf")] * (n+1)
    p.insert(0,0)
    s = [0] * (n+1)
    return (cut_rod_memoized_extended_aux(p, n, r, s), s)

def cut_rod_memoized_extended_aux(p, n, r, s):
    if r[n] >= 0:
        return r[n]

    best = float("-inf")
    if n == 0:
        best = 0
    else:
        for i in range(1, n+1):
            prev = cut_rod_memoized_extended_aux(p, n-i, r, s)
            if best < p[i] + prev:
                best = p[i] + prev
                s[n] = i

    r[n] = best

    return best

#
# Dynamic programming solution using bottom-up method
#
def cut_rod_bottom_up(p, n):
    p.insert(0, 0)
    r = [0] * (n+1)

    for j in range(1, n+1):
        best = float("-inf")
        for i in range(1, j+1):
            best = max(best, p[i] + r[j - i])
        r[j] = best

    return r[n]

#
# Returning the places to cut
#
def cut_rod_extended(p, n, c):
    p.insert(0,0)
    r = [0] * (n+1)
    s = [0] * (n+1)

    for j in range(1, n+1):
        best = float("-inf")
        for i in range(1, j+1):
            if best < p[i] + r[j-i]:
                best = p[i] + r[j-i]

                # if we ARE doing a cut,
                # subtract the price of the cut
                if j != i:
                    best = best - c

                s[j] = i
        r[j] = best

    return (r, s)

def cut_rod_print_solution(p, n):
    (r, s) = cut_rod_memoized_extended(p, n)
    while n > 0:
        print s[n]
        n = n - s[n]
    print r

#
# Adding a constant price for each cut
#
def cut_rod_price(p, n, c):
    p.insert(0, 0)
    r = [0] * (n+1)

    for j in range(1, n+1):
        best = float("-inf")
        for i in range(1, j+1):
            # We subtract the price from the current `best` solution
            best = max(best, p[i] + r[j - i])
        r[j] = best

    return r[-1]


p = [1, 5, 8, 9, 10, 17, 17, 20, 24, 30, 35, 35, 50, 70, 90, 96, 101, 112, 120, 125, 156]
#p = [4, 4, 3, 3, 3]
#print "Best: " + str(cut_rod_price(p, 5, 2))
#print str(cut_rod_memoized(p, 3))
cut_rod_print_solution(p, 16)
