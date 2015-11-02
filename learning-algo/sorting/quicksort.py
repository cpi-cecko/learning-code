def hoare_partition(ls, p, r):
    x = ls[p]
    i = p-1
    j = r+1
    while True:
        j=j-1
        while ls[j] > x:
            j=j-1
        i=i+1
        while ls[i] < x:
            i=i+1
        if i < j:
            ls[i], ls[j] = ls[j], ls[i]
        else:
            return j

def quicksort_hoare(ls, p, r):
    if p < r:
        q = hoare_partition(ls, p, r)
        # Hoare's partitioning algorithm puts the pivot element
        # in one of the partitions.
        quicksort_hoare(ls, p, q)
        quicksort_hoare(ls, q+1, r)


def partition(ls, p, r):
    x = ls[r]
    i = p-1
    for j in range(p, r):
        if ls[j] <= x:
            i = i+1
            ls[j], ls[i] = ls[i], ls[j]
    ls[r], ls[i+1] = ls[i+1], ls[r]
    return i+1

def quicksort(ls, p, r):
    if p < r:
        q = partition(ls, p, r)
        # The simple partitioning algorithm puts the pivot element
        # exactly between the partitions.
        quicksort(ls, p, q-1)
        quicksort(ls, q+1, r)

ls = [13,19,9,5,12,8,7,4,11,2,6,21]
quicksort(ls, 0, len(ls)-1)
print ls
