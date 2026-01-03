import heapq

n, m = map(int, input().split())

g = [[] for _ in range(n + 1)]

for _ in range(m):
    a, b, c = map(int, input().split())
    g[a].append((b, c))

INF = 10**30
dist = [INF] * (n + 1)
dist[1] = 0

pq = [(0, 1)]

while pq:
    d, u = heapq.heappop(pq)
    if d != dist[u]:
        continue
    for v, w in g[u]:
        nd = d + w
        if nd < dist[v]:
            dist[v] = nd
            heapq.heappush(pq, (nd, v))

print(dist[1], dist[2], dist[3])
