pragma solidity ^0.4.24;

/*
Example of how to verify BLS signatures and BGLS aggregate signatures in Ethereum.

Signatures are generated using https://github.com/Project-Arda/bgls
Code is based on https://github.com/jstoxrocky/zksnarks_example

*/

contract BLSExample {

    struct G1Point {
        uint X;
        uint Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    struct Validator {
        address user;
        uint256 amount;
        G1Point pubkey;
    }

    uint256 public vCount = 0;
    mapping (uint256 => Validator) public validators;

    function addValidator(uint256 amount, uint256 _pk,uint256 n) public {
        for(uint256 i=0;i<n;i++){
         vCount++;
         G1Point memory pk = mul(P1(), _pk+i);
         validators[vCount] = Validator(msg.sender,amount, pk);
        }
    }

    event pubkeyAgg(uint256 indexed X, uint256 indexed Y);
    event fourint(uint256 indexed X, uint256 indexed Y,uint256 indexed, uint256 );
    function checkSigAGG(uint256 bitmask, uint256[] memory sigs, uint256 message) public view returns(bool) {
        G1Point memory pubkey;

        for(uint256 i = 0; i <vCount; i++){
            // if((bitmask >> i) & 1 > 0) {
                // emit yo(i);
                Validator v = validators[i+1];
                pubkey = add(pubkey, v.pubkey);
                // pubkey.X += v.pubkey.X;
                // pubkey.Y += v.pubkey.Y;
            // }
        }
        emit pubkeyAgg(pubkey.X, pubkey.Y);

        G2Point memory H = hashToG2(message);
        G2Point memory signature = G2Point([sigs[0],sigs[1]],[sigs[2],sigs[3]]);
        return pairing2(negate(pubkey), H, P1(), signature);
    }
    function checkSigAGG1() public returns(bool) {
        G1Point memory pubkey = G1Point(17380323886581056473092238415087178747833394266216426706118377188344506669132, 8264330258127714892906603723635360533223500611780692134587255146148491007336);

        // for(uint256 i = 0; i <vCount; i++){
        //     // if((bitmask >> i) & 1 > 0) {
        //         // emit yo(i);
        //         Validator v = validators[i+1];
        //         pubkey = add(pubkey, v.pubkey);
        //         // pubkey.X += v.pubkey.X;
        //         // pubkey.Y += v.pubkey.Y;
        //     // }
        // }
    //G2Point([16102053849180588443131133900438094849149715436625045469236991987039241848240,
    //     7806540115951598708068323537226325143489341620121102987168061034219723055482],
    //  [15085587210032391178752839157819905008772577581989468040951987143794090031385,
    //  6718946360417026759307173704450430250787528919693688413464546568151449945362]);
        G2Point memory H = G2Point([
        7806540115951598708068323537226325143489341620121102987168061034219723055482,
        16102053849180588443131133900438094849149715436625045469236991987039241848240],
     [
     6718946360417026759307173704450430250787528919693688413464546568151449945362,
     15085587210032391178752839157819905008772577581989468040951987143794090031385]);
        // hashToG2(12312312345);
        // uint256 x1;
        // uint256 x2;
        // uint256 y1;
        // uint256 y2;
        // (x1,x2,y1,y2) = hashToG2T(12312312345);
        // H = G2Point([x1,x2],[y1,y2]);
        // emit fourint(x1,x2,y1,y2);
        // emit fourint(H.X[0],H.X[1],H.Y[0],H.Y[1]);
        G2Point memory signature = G2Point([
  20510297253563043906240734487189027213933976667621835319448331165769997484335,
  17039283792713629953217756598150981109636679343767085841835508695942368202923],
   [
    1985362097212581787757922254110217851026070065076532109495179805548055991837,
    7135647869386222135872517926452623520408611489591663660104271578165118400268]);
        // /"1",[17039283792713629953217756598150981109636679343767085841835508695942368202923, "20510297253563043906240734487189027213933976667621835319448331165769997484335",  7135647869386222135872517926452623520408611489591663660104271578165118400268, 1985362097212581787757922254110217851026070065076532109495179805548055991837],"12312312345"
        return pairing2(P1(), H, negate(pubkey), signature);
    }

    /// @return the generator of G1
    function P1() internal returns (G1Point) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781],

            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }

    //Example of BLS signature verification
    function verifyBLSTest() returns (bool) {

        bytes memory message = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";
        //1699131888237603253081745635795965149578805570377566526037684894920836698535,
        //          18449432681060975324996185106741716395381889030704944527420283723661542601758
        G1Point memory signature = G1Point(1699131888237603253081745635795965149578805570377566526037684894920836698535,18449432681060975324996185106741716395381889030704944527420283723661542601758);
    //   ((10543267229811279198977851047982463876857239651345060228059952687510927734143,
    //   1429512204204783650078826572944053009396281329823159408876501186677612162236),
    //   (4937291909223874394588015769154724463842148259278234932088759105031360685249,
    //   6536311701605246876230645890271381370017497395473286927019554997927477936597))
        G2Point memory v = G2Point(
            [10543267229811279198977851047982463876857239651345060228059952687510927734143, 1429512204204783650078826572944053009396281329823159408876501186677612162236],
            [4937291909223874394588015769154724463842148259278234932088759105031360685249, 6536311701605246876230645890271381370017497395473286927019554997927477936597]
        );

        G1Point memory h = hashToG1(message);

        return pairing2(negate(signature), P2(), h, v);
    }

    //Example of BGLS signature verification with 2 signers
    //Note that the messages differ in their last character.
    function verifyBGLS2() returns (bool) {

        uint numberOfSigners = 2;

        G1Point memory signature = G1Point(7985250684665362734034207174567341000146996823387166378141631317099216977152, 5471024627060516972461571110176333017668072838695251726406965080926450112048);

        bytes memory message0 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f30";
        bytes memory message1 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";

        G2Point memory v0 = G2Point(
            [15516709285352539082439213720585739724329002971882390582209636960597958801449, 19324541677661060388134143597417835654030498723817274130329567224531700170734],
            [16550775633156536193089672538964908973667410921848053632462693002610771214528, 10154483139478025296468271477739414260393126999813603835827647034319242387010]
        );

        G2Point memory v1 = G2Point(
            [14125383697019450293340447180826714775062600193406387386692146468060627933203, 10886345395648455940547500614900453787797209052692168129177801883734751834552],
            [13494666809312056575532152175382485778895768300692817869062640713829304801648, 10580958449683540742032499469496205826101096579572266360455646078388895706251]
        );

        G1Point memory h0 = hashToG1(message0);
        G1Point memory h1 = hashToG1(message1);

        G1Point[] memory a = new G1Point[](numberOfSigners + 1);
        G2Point[] memory b = new G2Point[](numberOfSigners + 1);
        a[0] = negate(signature);
        a[1] = h0;
        a[2] = h1;
        b[0] = P2();
        b[1] = v0;
        b[2] = v1;

        return pairing(a, b);
    }

    //Example of BGLS signature verification with 3 signers
    //Note that the messages differ in their last character.
    function verifyBGLS3() returns (bool) {

        uint numberOfSigners = 3;

        G1Point memory signature = G1Point(385846518441062319503502284295243290270560187383398932887791670182362540842, 19731933537428695151702009864745685458233056709189425720845387511061953267292);

        bytes memory message0 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f30";
        bytes memory message1 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";
        bytes memory message2 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f32";

        G2Point memory v0 = G2Point(
            [1787282038370667094324364195810339512415273589223814213215040505578200405366, 414568866548933554513940840943382696902163788831396286279770126458218272940],
            [6560020551439455112781785895092032589010633560844445112872109862153018855017, 19411093226570397520343120724285433000937737461010544490862811136406407315543]
        );

        G2Point memory v1 = G2Point(
            [14831125462625540363404323739936082597729714855858291605999144010730542058037, 8342129546329626371616639780890580451066604883761980695690870205390518348707],
            [808186590373043742842665711030588185456231663895663328011864547134240543671, 1856705676948889458735296604372981546875220644939188415241687241562401814459]
        );

        G2Point memory v2 = G2Point(
            [12507030828714819990408995725310388936101611986473926829733453468215798265704, 16402225253711577242710704509153100189802817297679524801952098990526969620006],
            [18717845356690477533392378472300056893077745517009561191866660997312973511514, 20124563173642533900823905467925868861151292863229012000403558815142682516349]
        );

        G1Point memory h0 = hashToG1(message0);
        G1Point memory h1 = hashToG1(message1);
        G1Point memory h2 = hashToG1(message2);

        G1Point[] memory a = new G1Point[](numberOfSigners + 1);
        G2Point[] memory b = new G2Point[](numberOfSigners + 1);
        a[0] = negate(signature);
        a[1] = h0;
        a[2] = h1;
        a[3] = h2;
        b[0] = P2();
        b[1] = v0;
        b[2] = v1;
        b[3] = v2;

        return pairing(a, b);
    }

    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);

        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }

        uint[1] memory out;
        bool success;

        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        // Use "invalid" to make gas estimation work
            switch success case 0 {invalid}
        }
        require(success);
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairing2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }

    function hashToG1(bytes message) internal returns (G1Point) {
        uint256 h = 12312312345;//uint256(keccak256(message));
        return mul(P1(), h);
    }

    function hashToG2(uint256 h) internal returns (G2Point memory) {
        // uint256 h = 12312312345;  //uint256(keccak256(message));
        G2Point memory p2 = P2();
        uint256 x1;
        uint256 x2;
        uint256 y1;
        uint256 y2;
        // (x1,x2,y1,y2) = BN256G2.ECTwistMul(h, p2.X[0], p2.X[1], p2.Y[0], p2.Y[1]);
        // G2Point memory g2 =;
        return G2Point([x1,x2],[y1,y2]);
    }
    function hashToG2T(uint256 h) public view returns (uint256,uint256,uint256,uint256) {
        // uint256 h = 12312312345;  //uint256(keccak256(message));
        G2Point memory p2 = P2();
        // uint256 x1;
        // uint256 x2;
        // uint256 y1;
        // uint256 y2;
        // (x1,x2,y1,y2) =
        // return BN256G2.ECTwistMul(h, p2.X[0], p2.X[1], p2.Y[0], p2.Y[1]);
        // G2Point memory g2 =;
        // return G2Point([x1,x2],[y1,y2]);
    }

    function modPow(uint256 base, uint256 exponent, uint256 modulus) internal returns (uint256) {
        uint256[6] memory input = [32, 32, 32, base, exponent, modulus];
        uint256[1] memory result;
        assembly {
            if iszero(call(not(0), 0x05, 0, input, 0xc0, result, 0x20)) {
                revert(0, 0)
            }
        }
        return result[0];
    }

    /// @return the negation of p, i.e. p.add(p.negate()) should be zero.
    function negate(G1Point p) internal returns (G1Point) {
        // The prime q in the base field F_q for G1
//        21888242871839275222246405745257275088696311157297823662689037894645226208583
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    /// @return the sum of two points of G1
    function add(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
        // Use "invalid" to make gas estimation work
            switch success case 0 {invalid}
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.mul(1) and p.add(p) == p.mul(2) for all points p.
    function mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
        // Use "invalid" to make gas estimation work
            switch success case 0 {invalid}
        }
        require(success);
    }
    function validator_(uint256 id) public view returns(address,uint256,uint256,uint256){
        return (validators[id].user,validators[id].amount,validators[id].pubkey.X,validators[id].pubkey.Y);
    }

}

/**
 * @title Elliptic curve operations on twist points for alt_bn128
 * @author Mustafa Al-Bassam (mus@musalbas.com)
 */
// library BN256G2 {
//     uint256 internal constant FIELD_MODULUS = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
//     uint256 internal constant TWISTBX = 0x2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5;
//     uint256 internal constant TWISTBY = 0x9713b03af0fed4cd2cafadeed8fdf4a74fa084e52d1852e4a2bd0685c315d2;
//     uint internal constant PTXX = 0;
//     uint internal constant PTXY = 1;
//     uint internal constant PTYX = 2;
//     uint internal constant PTYY = 3;
//     uint internal constant PTZX = 4;
//     uint internal constant PTZY = 5;

//     /**
//      * @notice Add two twist points
//      * @param pt1xx Coefficient 1 of x on point 1
//      * @param pt1xy Coefficient 2 of x on point 1
//      * @param pt1yx Coefficient 1 of y on point 1
//      * @param pt1yy Coefficient 2 of y on point 1
//      * @param pt2xx Coefficient 1 of x on point 2
//      * @param pt2xy Coefficient 2 of x on point 2
//      * @param pt2yx Coefficient 1 of y on point 2
//      * @param pt2yy Coefficient 2 of y on point 2
//      * @return (pt3xx, pt3xy, pt3yx, pt3yy)
//      */
//     function ECTwistAdd(
//         uint256 pt1xx, uint256 pt1xy,
//         uint256 pt1yx, uint256 pt1yy,
//         uint256 pt2xx, uint256 pt2xy,
//         uint256 pt2yx, uint256 pt2yy
//     ) public pure returns (
//         uint256, uint256,
//         uint256, uint256
//     ) {
//         if (
//             pt1xx == 0 && pt1xy == 0 &&
//             pt1yx == 0 && pt1yy == 0
//         ) {
//             if (!(
//                 pt2xx == 0 && pt2xy == 0 &&
//                 pt2yx == 0 && pt2yy == 0
//             )) {
//                 assert(_isOnCurve(
//                     pt2xx, pt2xy,
//                     pt2yx, pt2yy
//                 ));
//             }
//             return (
//                 pt2xx, pt2xy,
//                 pt2yx, pt2yy
//             );
//         } else if (
//             pt2xx == 0 && pt2xy == 0 &&
//             pt2yx == 0 && pt2yy == 0
//         ) {
//             assert(_isOnCurve(
//                 pt1xx, pt1xy,
//                 pt1yx, pt1yy
//             ));
//             return (
//                 pt1xx, pt1xy,
//                 pt1yx, pt1yy
//             );
//         }

//         assert(_isOnCurve(
//             pt1xx, pt1xy,
//             pt1yx, pt1yy
//         ));
//         assert(_isOnCurve(
//             pt2xx, pt2xy,
//             pt2yx, pt2yy
//         ));

//         uint256[6] memory pt3 = _ECTwistAddJacobian(
//             pt1xx, pt1xy,
//             pt1yx, pt1yy,
//             1,     0,
//             pt2xx, pt2xy,
//             pt2yx, pt2yy,
//             1,     0
//         );

//         return _fromJacobian(
//             pt3[PTXX], pt3[PTXY],
//             pt3[PTYX], pt3[PTYY],
//             pt3[PTZX], pt3[PTZY]
//         );
//     }

//     /**
//      * @notice Multiply a twist point by a scalar
//      * @param s     Scalar to multiply by
//      * @param pt1xx Coefficient 1 of x
//      * @param pt1xy Coefficient 2 of x
//      * @param pt1yx Coefficient 1 of y
//      * @param pt1yy Coefficient 2 of y
//      * @return (pt2xx, pt2xy, pt2yx, pt2yy)
//      */
//     function ECTwistMul(
//         uint256 s,
//         uint256 pt1xx, uint256 pt1xy,
//         uint256 pt1yx, uint256 pt1yy
//     ) public pure returns (
//         uint256, uint256,
//         uint256, uint256
//     ) {
//         uint256 pt1zx = 1;
//         if (
//             pt1xx == 0 && pt1xy == 0 &&
//             pt1yx == 0 && pt1yy == 0
//         ) {
//             pt1xx = 1;
//             pt1yx = 1;
//             pt1zx = 0;
//         } else {
//             assert(_isOnCurve(
//                 pt1xx, pt1xy,
//                 pt1yx, pt1yy
//             ));
//         }

//         uint256[6] memory pt2 = _ECTwistMulJacobian(
//             s,
//             pt1xx, pt1xy,
//             pt1yx, pt1yy,
//             pt1zx, 0
//         );

//         return _fromJacobian(
//             pt2[PTXX], pt2[PTXY],
//             pt2[PTYX], pt2[PTYY],
//             pt2[PTZX], pt2[PTZY]
//         );
//     }

//     /**
//      * @notice Get the field modulus
//      * @return The field modulus
//      */
//     function GetFieldModulus() public pure returns (uint256) {
//         return FIELD_MODULUS;
//     }

//     function submod(uint256 a, uint256 b, uint256 n) internal pure returns (uint256) {
//         return addmod(a, n - b, n);
//     }

//     function _FQ2Mul(
//         uint256 xx, uint256 xy,
//         uint256 yx, uint256 yy
//     ) internal pure returns(uint256, uint256) {
//         return (
//             submod(mulmod(xx, yx, FIELD_MODULUS), mulmod(xy, yy, FIELD_MODULUS), FIELD_MODULUS),
//             addmod(mulmod(xx, yy, FIELD_MODULUS), mulmod(xy, yx, FIELD_MODULUS), FIELD_MODULUS)
//         );
//     }

//     function _FQ2Muc(
//         uint256 xx, uint256 xy,
//         uint256 c
//     ) internal pure returns(uint256, uint256) {
//         return (
//             mulmod(xx, c, FIELD_MODULUS),
//             mulmod(xy, c, FIELD_MODULUS)
//         );
//     }

//     function _FQ2Add(
//         uint256 xx, uint256 xy,
//         uint256 yx, uint256 yy
//     ) internal pure returns(uint256, uint256) {
//         return (
//             addmod(xx, yx, FIELD_MODULUS),
//             addmod(xy, yy, FIELD_MODULUS)
//         );
//     }

//     function _FQ2Sub(
//         uint256 xx, uint256 xy,
//         uint256 yx, uint256 yy
//     ) internal pure returns(uint256 rx, uint256 ry) {
//         return (
//             submod(xx, yx, FIELD_MODULUS),
//             submod(xy, yy, FIELD_MODULUS)
//         );
//     }

//     function _FQ2Div(
//         uint256 xx, uint256 xy,
//         uint256 yx, uint256 yy
//     ) internal pure returns(uint256, uint256) {
//         (yx, yy) = _FQ2Inv(yx, yy);
//         return _FQ2Mul(xx, xy, yx, yy);
//     }

//     function _FQ2Inv(uint256 x, uint256 y) internal pure returns(uint256, uint256) {
//         uint256 inv = _modInv(addmod(mulmod(y, y, FIELD_MODULUS), mulmod(x, x, FIELD_MODULUS), FIELD_MODULUS), FIELD_MODULUS);
//         return (
//             mulmod(x, inv, FIELD_MODULUS),
//             FIELD_MODULUS - mulmod(y, inv, FIELD_MODULUS)
//         );
//     }

//     function _isOnCurve(
//         uint256 xx, uint256 xy,
//         uint256 yx, uint256 yy
//     ) internal pure returns (bool) {
//         uint256 yyx;
//         uint256 yyy;
//         uint256 xxxx;
//         uint256 xxxy;
//         (yyx, yyy) = _FQ2Mul(yx, yy, yx, yy);
//         (xxxx, xxxy) = _FQ2Mul(xx, xy, xx, xy);
//         (xxxx, xxxy) = _FQ2Mul(xxxx, xxxy, xx, xy);
//         (yyx, yyy) = _FQ2Sub(yyx, yyy, xxxx, xxxy);
//         (yyx, yyy) = _FQ2Sub(yyx, yyy, TWISTBX, TWISTBY);
//         return yyx == 0 && yyy == 0;
//     }

//     function _modInv(uint256 a, uint256 n) internal pure returns(uint256 t) {
//         t = 0;
//         uint256 newT = 1;
//         uint256 r = n;
//         uint256 newR = a;
//         uint256 q;
//         while (newR != 0) {
//             q = r / newR;
//             (t, newT) = (newT, submod(t, mulmod(q, newT, n), n));
//             (r, newR) = (newR, r - q * newR);
//         }
//     }

//     function _fromJacobian(
//         uint256 pt1xx, uint256 pt1xy,
//         uint256 pt1yx, uint256 pt1yy,
//         uint256 pt1zx, uint256 pt1zy
//     ) internal pure returns (
//         uint256 pt2xx, uint256 pt2xy,
//         uint256 pt2yx, uint256 pt2yy
//     ) {
//         uint256 invzx;
//         uint256 invzy;
//         (invzx, invzy) = _FQ2Inv(pt1zx, pt1zy);
//         (pt2xx, pt2xy) = _FQ2Mul(pt1xx, pt1xy, invzx, invzy);
//         (pt2yx, pt2yy) = _FQ2Mul(pt1yx, pt1yy, invzx, invzy);
//     }

//     function _ECTwistAddJacobian(
//         uint256 pt1xx, uint256 pt1xy,
//         uint256 pt1yx, uint256 pt1yy,
//         uint256 pt1zx, uint256 pt1zy,
//         uint256 pt2xx, uint256 pt2xy,
//         uint256 pt2yx, uint256 pt2yy,
//         uint256 pt2zx, uint256 pt2zy) internal pure returns (uint256[6] memory pt3) {
//             if (pt1zx == 0 && pt1zy == 0) {
//                 (
//                     pt3[PTXX], pt3[PTXY],
//                     pt3[PTYX], pt3[PTYY],
//                     pt3[PTZX], pt3[PTZY]
//                 ) = (
//                     pt2xx, pt2xy,
//                     pt2yx, pt2yy,
//                     pt2zx, pt2zy
//                 );
//                 return pt3;
//             } else if (pt2zx == 0 && pt2zy == 0) {
//                 (
//                     pt3[PTXX], pt3[PTXY],
//                     pt3[PTYX], pt3[PTYY],
//                     pt3[PTZX], pt3[PTZY]
//                 ) = (
//                     pt1xx, pt1xy,
//                     pt1yx, pt1yy,
//                     pt1zx, pt1zy
//                 );
//                 return pt3;
//             }

//             (pt2yx,     pt2yy)     = _FQ2Mul(pt2yx, pt2yy, pt1zx, pt1zy); // U1 = y2 * z1
//             (pt3[PTYX], pt3[PTYY]) = _FQ2Mul(pt1yx, pt1yy, pt2zx, pt2zy); // U2 = y1 * z2
//             (pt2xx,     pt2xy)     = _FQ2Mul(pt2xx, pt2xy, pt1zx, pt1zy); // V1 = x2 * z1
//             (pt3[PTZX], pt3[PTZY]) = _FQ2Mul(pt1xx, pt1xy, pt2zx, pt2zy); // V2 = x1 * z2

//             if (pt2xx == pt3[PTZX] && pt2xy == pt3[PTZY]) {
//                 if (pt2yx == pt3[PTYX] && pt2yy == pt3[PTYY]) {
//                     (
//                         pt3[PTXX], pt3[PTXY],
//                         pt3[PTYX], pt3[PTYY],
//                         pt3[PTZX], pt3[PTZY]
//                     ) = _ECTwistDoubleJacobian(pt1xx, pt1xy, pt1yx, pt1yy, pt1zx, pt1zy);
//                     return pt3;
//                 }
//                 (
//                     pt3[PTXX], pt3[PTXY],
//                     pt3[PTYX], pt3[PTYY],
//                     pt3[PTZX], pt3[PTZY]
//                 ) = (
//                     1, 0,
//                     1, 0,
//                     0, 0
//                 );
//                 return pt3;
//             }

//             (pt2zx,     pt2zy)     = _FQ2Mul(pt1zx, pt1zy, pt2zx,     pt2zy);     // W = z1 * z2
//             (pt1xx,     pt1xy)     = _FQ2Sub(pt2yx, pt2yy, pt3[PTYX], pt3[PTYY]); // U = U1 - U2
//             (pt1yx,     pt1yy)     = _FQ2Sub(pt2xx, pt2xy, pt3[PTZX], pt3[PTZY]); // V = V1 - V2
//             (pt1zx,     pt1zy)     = _FQ2Mul(pt1yx, pt1yy, pt1yx,     pt1yy);     // V_squared = V * V
//             (pt2yx,     pt2yy)     = _FQ2Mul(pt1zx, pt1zy, pt3[PTZX], pt3[PTZY]); // V_squared_times_V2 = V_squared * V2
//             (pt1zx,     pt1zy)     = _FQ2Mul(pt1zx, pt1zy, pt1yx,     pt1yy);     // V_cubed = V * V_squared
//             (pt3[PTZX], pt3[PTZY]) = _FQ2Mul(pt1zx, pt1zy, pt2zx,     pt2zy);     // newz = V_cubed * W
//             (pt2xx,     pt2xy)     = _FQ2Mul(pt1xx, pt1xy, pt1xx,     pt1xy);     // U * U
//             (pt2xx,     pt2xy)     = _FQ2Mul(pt2xx, pt2xy, pt2zx,     pt2zy);     // U * U * W
//             (pt2xx,     pt2xy)     = _FQ2Sub(pt2xx, pt2xy, pt1zx,     pt1zy);     // U * U * W - V_cubed
//             (pt2zx,     pt2zy)     = _FQ2Muc(pt2yx, pt2yy, 2);                    // 2 * V_squared_times_V2
//             (pt2xx,     pt2xy)     = _FQ2Sub(pt2xx, pt2xy, pt2zx,     pt2zy);     // A = U * U * W - V_cubed - 2 * V_squared_times_V2
//             (pt3[PTXX], pt3[PTXY]) = _FQ2Mul(pt1yx, pt1yy, pt2xx,     pt2xy);     // newx = V * A
//             (pt1yx,     pt1yy)     = _FQ2Sub(pt2yx, pt2yy, pt2xx,     pt2xy);     // V_squared_times_V2 - A
//             (pt1yx,     pt1yy)     = _FQ2Mul(pt1xx, pt1xy, pt1yx,     pt1yy);     // U * (V_squared_times_V2 - A)
//             (pt1xx,     pt1xy)     = _FQ2Mul(pt1zx, pt1zy, pt3[PTYX], pt3[PTYY]); // V_cubed * U2
//             (pt3[PTYX], pt3[PTYY]) = _FQ2Sub(pt1yx, pt1yy, pt1xx,     pt1xy);     // newy = U * (V_squared_times_V2 - A) - V_cubed * U2
//     }

//     function _ECTwistDoubleJacobian(
//         uint256 pt1xx, uint256 pt1xy,
//         uint256 pt1yx, uint256 pt1yy,
//         uint256 pt1zx, uint256 pt1zy
//     ) internal pure returns(
//         uint256 pt2xx, uint256 pt2xy,
//         uint256 pt2yx, uint256 pt2yy,
//         uint256 pt2zx, uint256 pt2zy
//     ) {
//         (pt2xx, pt2xy) = _FQ2Muc(pt1xx, pt1xy, 3);            // 3 * x
//         (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1xx, pt1xy); // W = 3 * x * x
//         (pt1zx, pt1zy) = _FQ2Mul(pt1yx, pt1yy, pt1zx, pt1zy); // S = y * z
//         (pt2yx, pt2yy) = _FQ2Mul(pt1xx, pt1xy, pt1yx, pt1yy); // x * y
//         (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt1zx, pt1zy); // B = x * y * S
//         (pt1xx, pt1xy) = _FQ2Mul(pt2xx, pt2xy, pt2xx, pt2xy); // W * W
//         (pt2zx, pt2zy) = _FQ2Muc(pt2yx, pt2yy, 8);            // 8 * B
//         (pt1xx, pt1xy) = _FQ2Sub(pt1xx, pt1xy, pt2zx, pt2zy); // H = W * W - 8 * B
//         (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt1zx, pt1zy); // S_squared = S * S
//         (pt2yx, pt2yy) = _FQ2Muc(pt2yx, pt2yy, 4);            // 4 * B
//         (pt2yx, pt2yy) = _FQ2Sub(pt2yx, pt2yy, pt1xx, pt1xy); // 4 * B - H
//         (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt2xx, pt2xy); // W * (4 * B - H)
//         (pt2xx, pt2xy) = _FQ2Muc(pt1yx, pt1yy, 8);            // 8 * y
//         (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1yx, pt1yy); // 8 * y * y
//         (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt2zx, pt2zy); // 8 * y * y * S_squared
//         (pt2yx, pt2yy) = _FQ2Sub(pt2yx, pt2yy, pt2xx, pt2xy); // newy = W * (4 * B - H) - 8 * y * y * S_squared
//         (pt2xx, pt2xy) = _FQ2Muc(pt1xx, pt1xy, 2);            // 2 * H
//         (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1zx, pt1zy); // newx = 2 * H * S
//         (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt2zx, pt2zy); // S * S_squared
//         (pt2zx, pt2zy) = _FQ2Muc(pt2zx, pt2zy, 8);            // newz = 8 * S * S_squared
//     }

//     function _ECTwistMulJacobian(
//         uint256 d,
//         uint256 pt1xx, uint256 pt1xy,
//         uint256 pt1yx, uint256 pt1yy,
//         uint256 pt1zx, uint256 pt1zy
//     ) internal pure returns(uint256[6] memory pt2) {
//         while (d != 0) {
//             if ((d & 1) != 0) {
//                 pt2 = _ECTwistAddJacobian(
//                     pt2[PTXX], pt2[PTXY],
//                     pt2[PTYX], pt2[PTYY],
//                     pt2[PTZX], pt2[PTZY],
//                     pt1xx, pt1xy,
//                     pt1yx, pt1yy,
//                     pt1zx, pt1zy);
//             }
//             (
//                 pt1xx, pt1xy,
//                 pt1yx, pt1yy,
//                 pt1zx, pt1zy
//             ) = _ECTwistDoubleJacobian(
//                 pt1xx, pt1xy,
//                 pt1yx, pt1yy,
//                 pt1zx, pt1zy
//             );

//             d = d / 2;
//         }
//     }
// }
/// tested
pragma solidity ^0.4.14;

/*
Example of how to verify BLS signatures and BGLS aggregate signatures in Ethereum.

Signatures are generated using https://github.com/Project-Arda/bgls
Code is based on https://github.com/jstoxrocky/zksnarks_example
*/

contract BLSExample {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    /// @return the generator of G1
    function P1() internal returns (G1Point) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal returns (G2Point) {
        //     return G2Point(
        //     [10857046999023057135944570762232829481370756359578518086990519993285655852781, 11559732032986387107991004021392285783925812861821192530917403151452391805634],
        //     [8495653923123431417604973247489272438418190587263600148770280649306958101930, 4082367875863433681332203403145435568316851327593401208105741076214120093531]
        // );
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781],

            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }

    //Example of BLS signature verification
    function verifyBLSTest() returns (bool) {

        bytes memory message = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";

        G1Point memory signature = G1Point(6479746447046570360435714249272776082787932146211764251347798668447381926167,11181692345848957662074290878138344227085597134981019040735323471731897153462);

        G2Point memory v = G2Point(
            [18523194229674161632574346342370534213928970227736813349975332190798837787897, 5725452645840548248571879966249653216818629536104756116202892528545334967238],
            [3816656720215352836236372430537606984911914992659540439626020770732736710924, 677280212051826798882467475639465784259337739185938192379192340908771705870]
        );

        G1Point memory h = hashToG1_(message);

        return pairing2(negate(signature), P2(), h, v);
    }
    function hashToG1_(bytes message) internal returns (G1Point) {
        uint256 h = 12312312345;//uint256(keccak256(message));
        return mul(P1(), h);
    }

    function verifyBLSTest1() returns (bool) {

        bytes memory message = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";
        //1699131888237603253081745635795965149578805570377566526037684894920836698535,
        //          18449432681060975324996185106741716395381889030704944527420283723661542601758
        G1Point memory signature = G1Point(1699131888237603253081745635795965149578805570377566526037684894920836698535, 18449432681060975324996185106741716395381889030704944527420283723661542601758);
    //   ((10543267229811279198977851047982463876857239651345060228059952687510927734143,
    //   1429512204204783650078826572944053009396281329823159408876501186677612162236),
    //   (4937291909223874394588015769154724463842148259278234932088759105031360685249,
    //   6536311701605246876230645890271381370017497395473286927019554997927477936597))
        G2Point memory v = G2Point(
            [1429512204204783650078826572944053009396281329823159408876501186677612162236, 10543267229811279198977851047982463876857239651345060228059952687510927734143],
            [6536311701605246876230645890271381370017497395473286927019554997927477936597, 4937291909223874394588015769154724463842148259278234932088759105031360685249]
        );

        G1Point memory h = hashToG1_(message);

        return pairing2(negate(signature), P2(), h, v);
    }

    //Example of BGLS signature verification with 2 signers
    //Note that the messages differ in their last character.
    function verifyBGLS2() returns (bool) {

        uint numberOfSigners = 2;

        G1Point memory signature = G1Point(7985250684665362734034207174567341000146996823387166378141631317099216977152, 5471024627060516972461571110176333017668072838695251726406965080926450112048);

        bytes memory message0 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f30";
        bytes memory message1 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";

        G2Point memory v0 = G2Point(
            [15516709285352539082439213720585739724329002971882390582209636960597958801449, 19324541677661060388134143597417835654030498723817274130329567224531700170734],
            [16550775633156536193089672538964908973667410921848053632462693002610771214528, 10154483139478025296468271477739414260393126999813603835827647034319242387010]
        );

        G2Point memory v1 = G2Point(
            [14125383697019450293340447180826714775062600193406387386692146468060627933203, 10886345395648455940547500614900453787797209052692168129177801883734751834552],
            [13494666809312056575532152175382485778895768300692817869062640713829304801648, 10580958449683540742032499469496205826101096579572266360455646078388895706251]
        );

        G1Point memory h0 = hashToG1(message0);
        G1Point memory h1 = hashToG1(message1);

        G1Point[] memory a = new G1Point[](numberOfSigners + 1);
        G2Point[] memory b = new G2Point[](numberOfSigners + 1);
        a[0] = negate(signature);
        a[1] = h0;
        a[2] = h1;
        b[0] = P2();
        b[1] = v0;
        b[2] = v1;

        return pairing(a, b);
    }

    //Example of BGLS signature verification with 3 signers
    //Note that the messages differ in their last character.
    function verifyBGLS3() returns (bool) {

        uint numberOfSigners = 3;

        G1Point memory signature = G1Point(385846518441062319503502284295243290270560187383398932887791670182362540842, 19731933537428695151702009864745685458233056709189425720845387511061953267292);

        bytes memory message0 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f30";
        bytes memory message1 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";
        bytes memory message2 = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f32";

        G2Point memory v0 = G2Point(
            [1787282038370667094324364195810339512415273589223814213215040505578200405366, 414568866548933554513940840943382696902163788831396286279770126458218272940],
            [6560020551439455112781785895092032589010633560844445112872109862153018855017, 19411093226570397520343120724285433000937737461010544490862811136406407315543]
        );

        G2Point memory v1 = G2Point(
            [14831125462625540363404323739936082597729714855858291605999144010730542058037, 8342129546329626371616639780890580451066604883761980695690870205390518348707],
            [808186590373043742842665711030588185456231663895663328011864547134240543671, 1856705676948889458735296604372981546875220644939188415241687241562401814459]
        );

        G2Point memory v2 = G2Point(
            [12507030828714819990408995725310388936101611986473926829733453468215798265704, 16402225253711577242710704509153100189802817297679524801952098990526969620006],
            [18717845356690477533392378472300056893077745517009561191866660997312973511514, 20124563173642533900823905467925868861151292863229012000403558815142682516349]
        );

        G1Point memory h0 = hashToG1(message0);
        G1Point memory h1 = hashToG1(message1);
        G1Point memory h2 = hashToG1(message2);

        G1Point[] memory a = new G1Point[](numberOfSigners + 1);
        G2Point[] memory b = new G2Point[](numberOfSigners + 1);
        a[0] = negate(signature);
        a[1] = h0;
        a[2] = h1;
        a[3] = h2;
        b[0] = P2();
        b[1] = v0;
        b[2] = v1;
        b[3] = v2;

        return pairing(a, b);
    }

    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);

        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }

        uint[1] memory out;
        bool success;

        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        // Use "invalid" to make gas estimation work
            switch success case 0 {invalid}
        }
        require(success);
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairing2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }

    function hashToG1(bytes message) internal returns (G1Point) {
        uint256 h = uint256(keccak256(message));
        return mul(P1(), h);
    }

    function modPow(uint256 base, uint256 exponent, uint256 modulus) internal returns (uint256) {
        uint256[6] memory input = [32, 32, 32, base, exponent, modulus];
        uint256[1] memory result;
        assembly {
            if iszero(call(not(0), 0x05, 0, input, 0xc0, result, 0x20)) {
                revert(0, 0)
            }
        }
        return result[0];
    }

    /// @return the negation of p, i.e. p.add(p.negate()) should be zero.
    function negate(G1Point p) internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    /// @return the sum of two points of G1
    function add(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
        // Use "invalid" to make gas estimation work
            switch success case 0 {invalid}
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.mul(1) and p.add(p) == p.mul(2) for all points p.
    function mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
        // Use "invalid" to make gas estimation work
            switch success case 0 {invalid}
        }
        require(success);
    }

}