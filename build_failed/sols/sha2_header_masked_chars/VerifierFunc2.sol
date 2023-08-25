// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "../VerifierFuncAbst.sol";

contract VerifierFunc2 is VerifierFuncAbst {
    function verifyPartial(
        uint256[] memory pubInputs,
        bytes memory proof,
        bool success,
        bytes32[] memory _transcript
    ) public view override returns (bool, bytes32[] memory) {
        bytes32[1351] memory transcript;
        for(uint i=0; i<_transcript.length; i++) {
            transcript[i] = _transcript[i];
        }
        assembly {{
            
            let f_p
            := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
            let
                f_q
            := 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
            function validate_ec_point(x, y) -> valid {
                {
                    let x_lt_p := lt(
                        x,
                        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    )
                    let y_lt_p := lt(
                        y,
                        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    )
                    valid := and(x_lt_p, y_lt_p)
                }
                {
                    let x_is_zero := eq(x, 0)
                    let y_is_zero := eq(y, 0)
                    let x_or_y_is_zero := or(x_is_zero, y_is_zero)
                    let x_and_y_is_not_zero := not(x_or_y_is_zero)
                    valid := and(x_and_y_is_not_zero, valid)
                }
                {
                    let y_square := mulmod(
                        y,
                        y,
                        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    )
                    let x_square := mulmod(
                        x,
                        x,
                        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    )
                    let x_cube := mulmod(
                        x_square,
                        x,
                        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    )
                    let x_cube_plus_3 := addmod(
                        x_cube,
                        3,
                        0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                    )
                    let y_square_eq_x_cube_plus_3 := eq(x_cube_plus_3, y_square)
                    valid := and(y_square_eq_x_cube_plus_3, valid)
                }
            }
    success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x8da0), 0x80, add(transcript, 0x8da0), 0x40), 1), success)
mstore(add(transcript, 0x8e20), 0x176c7f188b9344f15e4fbbac30e8d4dfd25eba285268c133bbc1617d68f63287)
                    mstore(add(transcript, 0x8e40), 0x29c66b26093b7c7da3f9b62dd58e998edb6a893c15b45d4752258bf16c658b07)
mstore(add(transcript, 0x8e60), mload(add(transcript, 0x6dc0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x8e20), 0x60, add(transcript, 0x8e20), 0x40), 1), success)
mstore(add(transcript, 0x8e80), mload(add(transcript, 0x8da0)))
                    mstore(add(transcript, 0x8ea0), mload(add(transcript, 0x8dc0)))
mstore(add(transcript, 0x8ec0), mload(add(transcript, 0x8e20)))
                    mstore(add(transcript, 0x8ee0), mload(add(transcript, 0x8e40)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x8e80), 0x80, add(transcript, 0x8e80), 0x40), 1), success)
mstore(add(transcript, 0x8f00), 0x19eaf69fd1815667d2ac2d6d6128cb9ddc69cc3a0c69bde25f8044e4b03d6c59)
                    mstore(add(transcript, 0x8f20), 0x1c2a9895da78cefe11a84c7ce7c4ff68f059ba7f5cff8cf2fa56131b3eddf475)
mstore(add(transcript, 0x8f40), mload(add(transcript, 0x6de0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x8f00), 0x60, add(transcript, 0x8f00), 0x40), 1), success)
mstore(add(transcript, 0x8f60), mload(add(transcript, 0x8e80)))
                    mstore(add(transcript, 0x8f80), mload(add(transcript, 0x8ea0)))
mstore(add(transcript, 0x8fa0), mload(add(transcript, 0x8f00)))
                    mstore(add(transcript, 0x8fc0), mload(add(transcript, 0x8f20)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x8f60), 0x80, add(transcript, 0x8f60), 0x40), 1), success)
mstore(add(transcript, 0x8fe0), 0x0ba11cdfafc3dba84bed5cba93c22c491a9d4c7e7e695b5d81ddd5919bdac9a3)
                    mstore(add(transcript, 0x9000), 0x19958ce33b1bebfb3dd25d803383ac47d8ec70b38e9f78c9bfe2acf300950aae)
mstore(add(transcript, 0x9020), mload(add(transcript, 0x6e00)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x8fe0), 0x60, add(transcript, 0x8fe0), 0x40), 1), success)
mstore(add(transcript, 0x9040), mload(add(transcript, 0x8f60)))
                    mstore(add(transcript, 0x9060), mload(add(transcript, 0x8f80)))
mstore(add(transcript, 0x9080), mload(add(transcript, 0x8fe0)))
                    mstore(add(transcript, 0x90a0), mload(add(transcript, 0x9000)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9040), 0x80, add(transcript, 0x9040), 0x40), 1), success)
mstore(add(transcript, 0x90c0), 0x060cde55cbe645150f92cf7ba1e7c3a4ff4a9a180811e6ff037a21d83927bc56)
                    mstore(add(transcript, 0x90e0), 0x16d7bbcc9be70d87f2bd4fd35ec419c54f5c7a04ab174e23ce24b3a69037fb07)
mstore(add(transcript, 0x9100), mload(add(transcript, 0x6e20)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x90c0), 0x60, add(transcript, 0x90c0), 0x40), 1), success)
mstore(add(transcript, 0x9120), mload(add(transcript, 0x9040)))
                    mstore(add(transcript, 0x9140), mload(add(transcript, 0x9060)))
mstore(add(transcript, 0x9160), mload(add(transcript, 0x90c0)))
                    mstore(add(transcript, 0x9180), mload(add(transcript, 0x90e0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9120), 0x80, add(transcript, 0x9120), 0x40), 1), success)
mstore(add(transcript, 0x91a0), 0x18b0331a7817140d021568874b52a58ef619dfe4a863572bdd799d10c5866097)
                    mstore(add(transcript, 0x91c0), 0x0858ff29c90ad26840551bbcd2be4e0d5d3cfa0183e6179ae9099cb6f7c1acd5)
mstore(add(transcript, 0x91e0), mload(add(transcript, 0x6e40)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x91a0), 0x60, add(transcript, 0x91a0), 0x40), 1), success)
mstore(add(transcript, 0x9200), mload(add(transcript, 0x9120)))
                    mstore(add(transcript, 0x9220), mload(add(transcript, 0x9140)))
mstore(add(transcript, 0x9240), mload(add(transcript, 0x91a0)))
                    mstore(add(transcript, 0x9260), mload(add(transcript, 0x91c0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9200), 0x80, add(transcript, 0x9200), 0x40), 1), success)
mstore(add(transcript, 0x9280), 0x128f0708226a2a4468f5d819ebe4b93f201bb5f8efd43596b10ababd986156df)
                    mstore(add(transcript, 0x92a0), 0x11d059eb4d12ac5722d9d2c834e08414417d7f71078cc3d6697496cf04e8e57c)
mstore(add(transcript, 0x92c0), mload(add(transcript, 0x6e60)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9280), 0x60, add(transcript, 0x9280), 0x40), 1), success)
mstore(add(transcript, 0x92e0), mload(add(transcript, 0x9200)))
                    mstore(add(transcript, 0x9300), mload(add(transcript, 0x9220)))
mstore(add(transcript, 0x9320), mload(add(transcript, 0x9280)))
                    mstore(add(transcript, 0x9340), mload(add(transcript, 0x92a0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x92e0), 0x80, add(transcript, 0x92e0), 0x40), 1), success)
mstore(add(transcript, 0x9360), 0x17aff03ce145d361c927fff808956d00750ee2f41d259f9bde15fa5cb05a4693)
                    mstore(add(transcript, 0x9380), 0x22d5e724646c2276b35288e787e6a2b7be4ae407a5ff11dcb733fe9665288fa4)
mstore(add(transcript, 0x93a0), mload(add(transcript, 0x6e80)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9360), 0x60, add(transcript, 0x9360), 0x40), 1), success)
mstore(add(transcript, 0x93c0), mload(add(transcript, 0x92e0)))
                    mstore(add(transcript, 0x93e0), mload(add(transcript, 0x9300)))
mstore(add(transcript, 0x9400), mload(add(transcript, 0x9360)))
                    mstore(add(transcript, 0x9420), mload(add(transcript, 0x9380)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x93c0), 0x80, add(transcript, 0x93c0), 0x40), 1), success)
mstore(add(transcript, 0x9440), 0x1b6dea5d6694f3f846e346df344d8820c4976a99881ac57740ade77ef4a75dc6)
                    mstore(add(transcript, 0x9460), 0x020c3cf2e4977bcce01d822c5f7c65b5e2f7ca839ac43ca4b5f180b7179bff0f)
mstore(add(transcript, 0x9480), mload(add(transcript, 0x6ea0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9440), 0x60, add(transcript, 0x9440), 0x40), 1), success)
mstore(add(transcript, 0x94a0), mload(add(transcript, 0x93c0)))
                    mstore(add(transcript, 0x94c0), mload(add(transcript, 0x93e0)))
mstore(add(transcript, 0x94e0), mload(add(transcript, 0x9440)))
                    mstore(add(transcript, 0x9500), mload(add(transcript, 0x9460)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x94a0), 0x80, add(transcript, 0x94a0), 0x40), 1), success)
mstore(add(transcript, 0x9520), 0x0041711784bd4cd0fc872f7e6ee6586473cc30b77dc8dabdba3b7f832f1bcf45)
                    mstore(add(transcript, 0x9540), 0x014ba7e3667e80c4558fbfb49bb5e73fc21c4555b5936fd8d397e3be72a4471f)
mstore(add(transcript, 0x9560), mload(add(transcript, 0x6ec0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9520), 0x60, add(transcript, 0x9520), 0x40), 1), success)
mstore(add(transcript, 0x9580), mload(add(transcript, 0x94a0)))
                    mstore(add(transcript, 0x95a0), mload(add(transcript, 0x94c0)))
mstore(add(transcript, 0x95c0), mload(add(transcript, 0x9520)))
                    mstore(add(transcript, 0x95e0), mload(add(transcript, 0x9540)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9580), 0x80, add(transcript, 0x9580), 0x40), 1), success)
mstore(add(transcript, 0x9600), 0x24433b3cd9aae21651a92080a5501d779d5c941d83badb6cb8dd4a0da89dcfb6)
                    mstore(add(transcript, 0x9620), 0x2a614dc92ef8b6f17b2649aa939c5c67d8c1b90f0562de9f798c5d0232cd9ead)
mstore(add(transcript, 0x9640), mload(add(transcript, 0x6ee0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9600), 0x60, add(transcript, 0x9600), 0x40), 1), success)
mstore(add(transcript, 0x9660), mload(add(transcript, 0x9580)))
                    mstore(add(transcript, 0x9680), mload(add(transcript, 0x95a0)))
mstore(add(transcript, 0x96a0), mload(add(transcript, 0x9600)))
                    mstore(add(transcript, 0x96c0), mload(add(transcript, 0x9620)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9660), 0x80, add(transcript, 0x9660), 0x40), 1), success)
mstore(add(transcript, 0x96e0), 0x289168dc34bb11977cd5b3ee5b0cc3b3cff59789fd4d8234bb9aeddd22977012)
                    mstore(add(transcript, 0x9700), 0x0916d69296ee04fa181ad2a4605612e0ed3032a8aa46551805f57c41dd43e7b8)
mstore(add(transcript, 0x9720), mload(add(transcript, 0x6f00)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x96e0), 0x60, add(transcript, 0x96e0), 0x40), 1), success)
mstore(add(transcript, 0x9740), mload(add(transcript, 0x9660)))
                    mstore(add(transcript, 0x9760), mload(add(transcript, 0x9680)))
mstore(add(transcript, 0x9780), mload(add(transcript, 0x96e0)))
                    mstore(add(transcript, 0x97a0), mload(add(transcript, 0x9700)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9740), 0x80, add(transcript, 0x9740), 0x40), 1), success)
mstore(add(transcript, 0x97c0), 0x17835eb6650813fb7f60e89d249a76fb7b48614c5fde9afbbeacf9d28954a7e4)
                    mstore(add(transcript, 0x97e0), 0x0cda3658e6e10bd3e7d69b03c7a2c19b7336fed75a5ee415ee75da538cd5348d)
mstore(add(transcript, 0x9800), mload(add(transcript, 0x6f20)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x97c0), 0x60, add(transcript, 0x97c0), 0x40), 1), success)
mstore(add(transcript, 0x9820), mload(add(transcript, 0x9740)))
                    mstore(add(transcript, 0x9840), mload(add(transcript, 0x9760)))
mstore(add(transcript, 0x9860), mload(add(transcript, 0x97c0)))
                    mstore(add(transcript, 0x9880), mload(add(transcript, 0x97e0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9820), 0x80, add(transcript, 0x9820), 0x40), 1), success)
mstore(add(transcript, 0x98a0), mload(add(transcript, 0x820)))
                    mstore(add(transcript, 0x98c0), mload(add(transcript, 0x840)))
mstore(add(transcript, 0x98e0), mload(add(transcript, 0x6f40)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x98a0), 0x60, add(transcript, 0x98a0), 0x40), 1), success)
mstore(add(transcript, 0x9900), mload(add(transcript, 0x9820)))
                    mstore(add(transcript, 0x9920), mload(add(transcript, 0x9840)))
mstore(add(transcript, 0x9940), mload(add(transcript, 0x98a0)))
                    mstore(add(transcript, 0x9960), mload(add(transcript, 0x98c0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9900), 0x80, add(transcript, 0x9900), 0x40), 1), success)
mstore(add(transcript, 0x9980), mload(add(transcript, 0x860)))
                    mstore(add(transcript, 0x99a0), mload(add(transcript, 0x880)))
mstore(add(transcript, 0x99c0), mload(add(transcript, 0x6f60)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9980), 0x60, add(transcript, 0x9980), 0x40), 1), success)
mstore(add(transcript, 0x99e0), mload(add(transcript, 0x9900)))
                    mstore(add(transcript, 0x9a00), mload(add(transcript, 0x9920)))
mstore(add(transcript, 0x9a20), mload(add(transcript, 0x9980)))
                    mstore(add(transcript, 0x9a40), mload(add(transcript, 0x99a0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x99e0), 0x80, add(transcript, 0x99e0), 0x40), 1), success)
mstore(add(transcript, 0x9a60), mload(add(transcript, 0x8a0)))
                    mstore(add(transcript, 0x9a80), mload(add(transcript, 0x8c0)))
mstore(add(transcript, 0x9aa0), mload(add(transcript, 0x6f80)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9a60), 0x60, add(transcript, 0x9a60), 0x40), 1), success)
mstore(add(transcript, 0x9ac0), mload(add(transcript, 0x99e0)))
                    mstore(add(transcript, 0x9ae0), mload(add(transcript, 0x9a00)))
mstore(add(transcript, 0x9b00), mload(add(transcript, 0x9a60)))
                    mstore(add(transcript, 0x9b20), mload(add(transcript, 0x9a80)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9ac0), 0x80, add(transcript, 0x9ac0), 0x40), 1), success)
mstore(add(transcript, 0x9b40), mload(add(transcript, 0x780)))
                    mstore(add(transcript, 0x9b60), mload(add(transcript, 0x7a0)))
mstore(add(transcript, 0x9b80), mload(add(transcript, 0x6fa0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9b40), 0x60, add(transcript, 0x9b40), 0x40), 1), success)
mstore(add(transcript, 0x9ba0), mload(add(transcript, 0x9ac0)))
                    mstore(add(transcript, 0x9bc0), mload(add(transcript, 0x9ae0)))
mstore(add(transcript, 0x9be0), mload(add(transcript, 0x9b40)))
                    mstore(add(transcript, 0x9c00), mload(add(transcript, 0x9b60)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9ba0), 0x80, add(transcript, 0x9ba0), 0x40), 1), success)
mstore(add(transcript, 0x9c20), mload(add(transcript, 0x540)))
                    mstore(add(transcript, 0x9c40), mload(add(transcript, 0x560)))
mstore(add(transcript, 0x9c60), mload(add(transcript, 0x73c0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9c20), 0x60, add(transcript, 0x9c20), 0x40), 1), success)
mstore(add(transcript, 0x9c80), mload(add(transcript, 0x9ba0)))
                    mstore(add(transcript, 0x9ca0), mload(add(transcript, 0x9bc0)))
mstore(add(transcript, 0x9cc0), mload(add(transcript, 0x9c20)))
                    mstore(add(transcript, 0x9ce0), mload(add(transcript, 0x9c40)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9c80), 0x80, add(transcript, 0x9c80), 0x40), 1), success)
mstore(add(transcript, 0x9d00), mload(add(transcript, 0x580)))
                    mstore(add(transcript, 0x9d20), mload(add(transcript, 0x5a0)))
mstore(add(transcript, 0x9d40), mload(add(transcript, 0x73e0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9d00), 0x60, add(transcript, 0x9d00), 0x40), 1), success)
mstore(add(transcript, 0x9d60), mload(add(transcript, 0x9c80)))
                    mstore(add(transcript, 0x9d80), mload(add(transcript, 0x9ca0)))
mstore(add(transcript, 0x9da0), mload(add(transcript, 0x9d00)))
                    mstore(add(transcript, 0x9dc0), mload(add(transcript, 0x9d20)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9d60), 0x80, add(transcript, 0x9d60), 0x40), 1), success)
mstore(add(transcript, 0x9de0), mload(add(transcript, 0x5c0)))
                    mstore(add(transcript, 0x9e00), mload(add(transcript, 0x5e0)))
mstore(add(transcript, 0x9e20), mload(add(transcript, 0x7400)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9de0), 0x60, add(transcript, 0x9de0), 0x40), 1), success)
mstore(add(transcript, 0x9e40), mload(add(transcript, 0x9d60)))
                    mstore(add(transcript, 0x9e60), mload(add(transcript, 0x9d80)))
mstore(add(transcript, 0x9e80), mload(add(transcript, 0x9de0)))
                    mstore(add(transcript, 0x9ea0), mload(add(transcript, 0x9e00)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9e40), 0x80, add(transcript, 0x9e40), 0x40), 1), success)
mstore(add(transcript, 0x9ec0), mload(add(transcript, 0x600)))
                    mstore(add(transcript, 0x9ee0), mload(add(transcript, 0x620)))
mstore(add(transcript, 0x9f00), mload(add(transcript, 0x7420)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9ec0), 0x60, add(transcript, 0x9ec0), 0x40), 1), success)
mstore(add(transcript, 0x9f20), mload(add(transcript, 0x9e40)))
                    mstore(add(transcript, 0x9f40), mload(add(transcript, 0x9e60)))
mstore(add(transcript, 0x9f60), mload(add(transcript, 0x9ec0)))
                    mstore(add(transcript, 0x9f80), mload(add(transcript, 0x9ee0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0x9f20), 0x80, add(transcript, 0x9f20), 0x40), 1), success)
mstore(add(transcript, 0x9fa0), mload(add(transcript, 0x640)))
                    mstore(add(transcript, 0x9fc0), mload(add(transcript, 0x660)))
mstore(add(transcript, 0x9fe0), mload(add(transcript, 0x7440)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0x9fa0), 0x60, add(transcript, 0x9fa0), 0x40), 1), success)
mstore(add(transcript, 0xa000), mload(add(transcript, 0x9f20)))
                    mstore(add(transcript, 0xa020), mload(add(transcript, 0x9f40)))
mstore(add(transcript, 0xa040), mload(add(transcript, 0x9fa0)))
                    mstore(add(transcript, 0xa060), mload(add(transcript, 0x9fc0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa000), 0x80, add(transcript, 0xa000), 0x40), 1), success)
mstore(add(transcript, 0xa080), mload(add(transcript, 0x680)))
                    mstore(add(transcript, 0xa0a0), mload(add(transcript, 0x6a0)))
mstore(add(transcript, 0xa0c0), mload(add(transcript, 0x7460)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa080), 0x60, add(transcript, 0xa080), 0x40), 1), success)
mstore(add(transcript, 0xa0e0), mload(add(transcript, 0xa000)))
                    mstore(add(transcript, 0xa100), mload(add(transcript, 0xa020)))
mstore(add(transcript, 0xa120), mload(add(transcript, 0xa080)))
                    mstore(add(transcript, 0xa140), mload(add(transcript, 0xa0a0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa0e0), 0x80, add(transcript, 0xa0e0), 0x40), 1), success)
mstore(add(transcript, 0xa160), mload(add(transcript, 0x6c0)))
                    mstore(add(transcript, 0xa180), mload(add(transcript, 0x6e0)))
mstore(add(transcript, 0xa1a0), mload(add(transcript, 0x76a0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa160), 0x60, add(transcript, 0xa160), 0x40), 1), success)
mstore(add(transcript, 0xa1c0), mload(add(transcript, 0xa0e0)))
                    mstore(add(transcript, 0xa1e0), mload(add(transcript, 0xa100)))
mstore(add(transcript, 0xa200), mload(add(transcript, 0xa160)))
                    mstore(add(transcript, 0xa220), mload(add(transcript, 0xa180)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa1c0), 0x80, add(transcript, 0xa1c0), 0x40), 1), success)
mstore(add(transcript, 0xa240), mload(add(transcript, 0x700)))
                    mstore(add(transcript, 0xa260), mload(add(transcript, 0x720)))
mstore(add(transcript, 0xa280), mload(add(transcript, 0x76c0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa240), 0x60, add(transcript, 0xa240), 0x40), 1), success)
mstore(add(transcript, 0xa2a0), mload(add(transcript, 0xa1c0)))
                    mstore(add(transcript, 0xa2c0), mload(add(transcript, 0xa1e0)))
mstore(add(transcript, 0xa2e0), mload(add(transcript, 0xa240)))
                    mstore(add(transcript, 0xa300), mload(add(transcript, 0xa260)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa2a0), 0x80, add(transcript, 0xa2a0), 0x40), 1), success)
mstore(add(transcript, 0xa320), mload(add(transcript, 0x740)))
                    mstore(add(transcript, 0xa340), mload(add(transcript, 0x760)))
mstore(add(transcript, 0xa360), mload(add(transcript, 0x76e0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa320), 0x60, add(transcript, 0xa320), 0x40), 1), success)
mstore(add(transcript, 0xa380), mload(add(transcript, 0xa2a0)))
                    mstore(add(transcript, 0xa3a0), mload(add(transcript, 0xa2c0)))
mstore(add(transcript, 0xa3c0), mload(add(transcript, 0xa320)))
                    mstore(add(transcript, 0xa3e0), mload(add(transcript, 0xa340)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa380), 0x80, add(transcript, 0xa380), 0x40), 1), success)
mstore(add(transcript, 0xa400), mload(add(transcript, 0x380)))
                    mstore(add(transcript, 0xa420), mload(add(transcript, 0x3a0)))
mstore(add(transcript, 0xa440), mload(add(transcript, 0x7880)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa400), 0x60, add(transcript, 0xa400), 0x40), 1), success)
mstore(add(transcript, 0xa460), mload(add(transcript, 0xa380)))
                    mstore(add(transcript, 0xa480), mload(add(transcript, 0xa3a0)))
mstore(add(transcript, 0xa4a0), mload(add(transcript, 0xa400)))
                    mstore(add(transcript, 0xa4c0), mload(add(transcript, 0xa420)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa460), 0x80, add(transcript, 0xa460), 0x40), 1), success)
mstore(add(transcript, 0xa4e0), mload(add(transcript, 0x400)))
                    mstore(add(transcript, 0xa500), mload(add(transcript, 0x420)))
mstore(add(transcript, 0xa520), mload(add(transcript, 0x78a0)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa4e0), 0x60, add(transcript, 0xa4e0), 0x40), 1), success)
mstore(add(transcript, 0xa540), mload(add(transcript, 0xa460)))
                    mstore(add(transcript, 0xa560), mload(add(transcript, 0xa480)))
mstore(add(transcript, 0xa580), mload(add(transcript, 0xa4e0)))
                    mstore(add(transcript, 0xa5a0), mload(add(transcript, 0xa500)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa540), 0x80, add(transcript, 0xa540), 0x40), 1), success)
mstore(add(transcript, 0xa5c0), mload(add(transcript, 0x1540)))
                    mstore(add(transcript, 0xa5e0), mload(add(transcript, 0x1560)))
mstore(add(transcript, 0xa600), sub(f_q, mload(add(transcript, 0x78e0))))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa5c0), 0x60, add(transcript, 0xa5c0), 0x40), 1), success)
mstore(add(transcript, 0xa620), mload(add(transcript, 0xa540)))
                    mstore(add(transcript, 0xa640), mload(add(transcript, 0xa560)))
mstore(add(transcript, 0xa660), mload(add(transcript, 0xa5c0)))
                    mstore(add(transcript, 0xa680), mload(add(transcript, 0xa5e0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa620), 0x80, add(transcript, 0xa620), 0x40), 1), success)
mstore(add(transcript, 0xa6a0), mload(add(transcript, 0x15e0)))
                    mstore(add(transcript, 0xa6c0), mload(add(transcript, 0x1600)))
mstore(add(transcript, 0xa6e0), mload(add(transcript, 0x7900)))
success := and(eq(staticcall(gas(), 0x7, add(transcript, 0xa6a0), 0x60, add(transcript, 0xa6a0), 0x40), 1), success)
mstore(add(transcript, 0xa700), mload(add(transcript, 0xa620)))
                    mstore(add(transcript, 0xa720), mload(add(transcript, 0xa640)))
mstore(add(transcript, 0xa740), mload(add(transcript, 0xa6a0)))
                    mstore(add(transcript, 0xa760), mload(add(transcript, 0xa6c0)))
success := and(eq(staticcall(gas(), 0x6, add(transcript, 0xa700), 0x80, add(transcript, 0xa700), 0x40), 1), success)
mstore(add(transcript, 0xa780), mload(add(transcript, 0xa700)))
                    mstore(add(transcript, 0xa7a0), mload(add(transcript, 0xa720)))
mstore(add(transcript, 0xa7c0), 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
            mstore(add(transcript, 0xa7e0), 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
            mstore(add(transcript, 0xa800), 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
            mstore(add(transcript, 0xa820), 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
mstore(add(transcript, 0xa840), mload(add(transcript, 0x15e0)))
                    mstore(add(transcript, 0xa860), mload(add(transcript, 0x1600)))
mstore(add(transcript, 0xa880), 0x02bb08cd02255f03f68752a49670aff168f06c4dc3e61da06dc4c01f0fdcd224)
            mstore(add(transcript, 0xa8a0), 0x172011b5a9f869c9c43b284680eec21bca494674b484f92bd4deba7511c686ce)
            mstore(add(transcript, 0xa8c0), 0x1b3856aa8ebe922476cec5710d73672c1bff1476980854b2978d07a9f8eaca72)
            mstore(add(transcript, 0xa8e0), 0x24c10b4979af6e3215b78d5d2ac15148b7030f658117741046443d6acbcdef0c)
success := and(eq(staticcall(gas(), 0x8, add(transcript, 0xa780), 0x180, add(transcript, 0xa780), 0x20), 1), success)
success := and(eq(mload(add(transcript, 0xa780)), 1), success)

        }}
        // transcriptBytes = abi.encode(transcript.length, transcript);
        bytes32[] memory newTranscript = new bytes32[](_transcript.length);
        for(uint i=0; i<_transcript.length; i++) {
            newTranscript[i] = transcript[i];
        }
        return (success, newTranscript);
    } 
}
