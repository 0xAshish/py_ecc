from py_ecc.bn128 import pairing
from py_ecc.bn128.bn128_curve import multiply, G1, G2, add


def testKeyAggregation():
    n = 20
    startPK = 35
    pks = [x for x in range(startPK, startPK+35)]


    pubs = [multiply(G2, x) for x in pks]
    for i in range(len(pubs)):
        print([pubs[i]],"\n")
    print(pubs)

    pubKeyAgg = pubs[0]
    for i in range(1,35):
        pubKeyAgg = add(pubKeyAgg, pubs[i])

    h = 12312312345
    H = multiply(G1, h)
    sigs = []
    for i in range(0, 35):
        sigs.append(multiply(H,pks[i]))


    aggSign = sigs[0]
    for i in range(1,35):
        aggSign = add(aggSign, sigs[i])


                # G2, G1
    pairing1 = pairing(pubKeyAgg, H)
                # G2 , G1
    pairing2 = pairing(G2, aggSign)
    assert pairing1 == pairing2  # test sign Aggregation

    print("yey")

testKeyAggregation()