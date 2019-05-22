from py_ecc.bn128 import pairing
from py_ecc.bn128.bn128_curve import multiply, G1, G2, add


def testKeyAggregation():
    privKey1 = 31
    privKey2 = 35
    privKey3 = 37


    pubKey1 = multiply(G1, privKey1)
    pubKey2 = multiply(G1, privKey2)
    pubKey3 = multiply(G1, privKey3)



    pubKeyAgg = add(add(pubKey1, pubKey2), pubKey3)

    h = 12312312345
    H = multiply(G2, h)

    sign1 = multiply(H, privKey1)
    sign2 = multiply(H, privKey2)
    sign3 = multiply(H, privKey3)


    aggSign = add(add(sign1, sign2), sign3)

    pairing1 = pairing(H, pubKeyAgg)
    pairing2 = pairing(aggSign, G1)
    assert pairing1 == pairing2  # test sign Aggregation
    # for 400/n validators
    # n = 400
    # startPK = 500
    # pks = [x for x in range(startPK, startPK + n)]
    #
    # pubs = [multiply(G1, x) for x in pks]
    # # for i in range(len(pubs)):
    # #     print([pubs[i]], "\n")
    # # print(pubs)
    #
    # pubKeyAgg = pubs[0]
    # for i in range(1, n):
    #     pubKeyAgg = add(pubKeyAgg, pubs[i])
    # h = 12312312345
    # H = multiply(G2, h)
    # sigs = []
    # for i in range(0, n):
    #     sigs.append(multiply(H,pks[i]))
    #
    #
    # aggSign = sigs[0]
    # for i in range(1, n):
    #     aggSign = add(aggSign, sigs[i])
    #
    # pairing1 = pairing(H, pubKeyAgg)
    # pairing2 = pairing(aggSign, G1)

    # assert pairing1 == pairing2  # test sign Aggregation
    # x = pubKeyAgg

    print("yey")

testKeyAggregation()

### 150 => 429695 + 100k
### 100 => 294400
### 400 => 1115547





