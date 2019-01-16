from py_ecc.bn128 import pairing
from py_ecc.bn128.bn128_curve import multiply, G1, G2, add


def testKeyAggregation():
    privKey1 = 31
    privKey2 = 35
    privKey3 = 37

    privKey4 = privKey1 + privKey2 + privKey3

    pubKey1 = multiply(G2, privKey1)
    pubKey2 = multiply(G2, privKey2)
    pubKey3 = multiply(G2, privKey3)


    pubKey4 = multiply(G2, privKey4)

    pubKeyAgg = add(add(pubKey1, pubKey2), pubKey3)

    h = 12312312345
    H = multiply(G1, h)

    sign1 = multiply(H, privKey1)
    sign2 = multiply(H, privKey2)
    sign3 = multiply(H, privKey3)

    sign4 = multiply(H, privKey4)

    aggSign = add(add(sign1, sign2), sign3)

    pairing1 = pairing(pubKeyAgg, H)
    pairing2 = pairing(G2, aggSign)
    assert pairing1 == pairing2  # test sign Aggregation

    pairing3 = pairing(G2, sign4)
    assert sign4 == aggSign  # test privkey Aggregation

    assert pairing1 == pairing3
    print("yey")

testKeyAggregation()
