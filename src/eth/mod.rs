// use crate::snark_verifier_sdk::*;
use crate::config_params::default_config_params;
use crate::*;
use ethereum_types::{Address, H256, U256};
use ethers::solc::artifacts::Contract;
use ethers::solc::{CompilerInput, EvmVersion, Solc};
use ethers::types::transaction::eip2718::TypedTransaction;
use ethers::types::{Bytes, TransactionRequest};
use halo2_base::halo2_proofs::circuit::Value;
use halo2_base::halo2_proofs::halo2curves::bn256::{self, Bn256, Fq, Fr, G1Affine};
use halo2_base::halo2_proofs::halo2curves::FieldExt;
use halo2_base::halo2_proofs::plonk::{Error, ProvingKey, VerifyingKey};
use halo2_base::halo2_proofs::poly::commitment::{Params, ParamsProver};
use halo2_base::halo2_proofs::poly::kzg::commitment::ParamsKZG;
use halo2_base::halo2_proofs::SerdeFormat;
use hex;
use itertools::Itertools;
use num_bigint::BigUint;
use rand::rngs::OsRng;
use rand::thread_rng;
use regex_simple::Regex;
use rsa::PublicKeyParts;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use snark_verifier::loader::evm::{compile_yul, EvmLoader, ExecutorBuilder};
use snark_verifier::loader::LoadedScalar;
use snark_verifier::pcs::kzg::{Bdfg21, Kzg};
use snark_verifier::system::halo2::transcript::evm::EvmTranscript;
use snark_verifier::system::halo2::{compile, Config};
use snark_verifier::verifier::PlonkVerifier;
use snark_verifier_sdk::evm::{encode_calldata, evm_verify, gen_evm_proof_shplonk};
use snark_verifier_sdk::halo2::aggregation::PublicAggregationCircuit;
use snark_verifier_sdk::halo2::{gen_proof_shplonk, gen_snark_shplonk};
use snark_verifier_sdk::Plonk;
use snark_verifier_sdk::{gen_pk, CircuitExt, LIMBS};
use std::env::set_var;
use std::fs::{self, File};
use std::io::{BufRead, BufReader, BufWriter, Read, Write};
use std::os::unix::prelude::OsStrExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::rc::Rc;
use std::sync::Arc;
use std::time::Duration;
pub mod gen_verifier;
use crate::eth::gen_verifier::*;
use ethers::abi::{encode, Abi, Function, Param, ParamType, Token, Tokenize};
use ethers::contract::ContractFactory;
use ethers::core::k256::ecdsa::SigningKey;
use ethers::middleware::SignerMiddleware;
use ethers::providers::{Http, Middleware, Provider};
use ethers::signers::Signer;
use ethers::{
    prelude::{abigen, LocalWallet, Wallet},
    utils::{Anvil, AnvilInstance},
};
abigen!(EmailVerifier, "./src/eth/EmailVerifier.abi");

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct DeployParamsJson {
    max_transcript_addr: u32,
    num_func_contracts: usize,
}

// original: https://github.com/zkonduit/ezkl/blob/main/src/eth.rs#L40
pub type EthersClient = Arc<SignerMiddleware<Provider<Http>, Wallet<SigningKey>>>;

// original: https://github.com/zkonduit/ezkl/blob/main/src/eth.rs#L58-L86
pub async fn setup_eth_backend() -> AnvilInstance {
    // Launch anvil
    let anvil = Anvil::new().arg("--gas-limit").arg("1000000000").spawn();
    anvil
}

// original: https://github.com/zkonduit/ezkl/blob/main/src/eth.rs#L58-L86
pub async fn setup_eth_client(anvil: &AnvilInstance) -> EthersClient {
    let wallet: LocalWallet = anvil.keys()[0].clone().into();

    let endpoint = anvil.endpoint();
    // println!("endpoint {}", endpoint);
    // let endpoint: &str = "http://localhost:8545";
    // Connect to the network
    let provider = Provider::<Http>::try_from(endpoint)
        .expect("fail to construct the provider")
        .interval(Duration::from_millis(10u64));
    // Instantiate the client with the wallet
    let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));
    client
}

use revm::{
    primitives::{Address as RAddress, CreateScheme, ExecutionResult, Output, TransactTo, TxEnv},
    InMemoryDB, EVM,
};
use std::str;

pub struct Evm {
    evm: EVM<InMemoryDB>,
}

impl Evm {
    pub fn new() -> Self {
        Self {
            evm: EVM {
                env: Default::default(),
                db: Some(Default::default()),
            },
        }
    }

    pub fn codesize(&mut self, address: RAddress) -> usize {
        self.evm.db.as_ref().unwrap().accounts[&address].info.code.as_ref().unwrap().len()
    }

    pub fn create(&mut self, bytecode: Vec<u8>) -> RAddress {
        let (_, output) = self.transact_success_or_panic(TxEnv {
            gas_limit: u64::MAX,
            transact_to: TransactTo::Create(CreateScheme::Create),
            data: bytecode.into(),
            ..Default::default()
        });
        match output {
            Output::Create(_, Some(address)) => address,
            _ => unreachable!(),
        }
    }

    pub fn call(&mut self, address: RAddress, calldata: Vec<u8>) -> (u64, Vec<u8>) {
        let (gas_used, output) = self.transact_success_or_panic(TxEnv {
            gas_limit: u64::MAX,
            transact_to: TransactTo::Call(address),
            data: calldata.into(),
            ..Default::default()
        });
        match output {
            Output::Call(output) => (gas_used, output.into()),
            _ => unreachable!(),
        }
    }

    fn transact_success_or_panic(&mut self, tx: TxEnv) -> (u64, Output) {
        self.evm.env.tx = tx;
        let result = self.evm.transact_commit().unwrap();
        self.evm.env.tx = Default::default();
        match result {
            ExecutionResult::Success { gas_used, output, logs, .. } => {
                if !logs.is_empty() {
                    println!("--- logs from {} ---", logs[0].address);
                    for log in logs {
                        println!("topic1: {:?}", log.topics[0]);
                    }
                    println!("--- end ---");
                }
                (gas_used, output)
            }
            ExecutionResult::Revert { gas_used, output } => panic!("Transaction reverts with gas_used {gas_used} and output {:#x}", output),
            ExecutionResult::Halt { reason, gas_used } => panic!("Transaction halts unexpectedly with gas_used {gas_used} and reason {:?}", reason),
        }
    }
}

pub fn compile_solidity(solidity: impl AsRef<[u8]>) -> Vec<u8> {
    let mut cmd = Command::new("solc")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .arg("--bin")
        .arg("--via-ir")
        .arg("-")
        .spawn()
        .unwrap();
    cmd.stdin.take().unwrap().write_all(solidity.as_ref()).unwrap();
    let output = cmd.wait_with_output().unwrap();
    let stdout = str::from_utf8(&output.stdout).unwrap();
    if let Some(binary) = find_binary(stdout) {
        binary
    } else {
        panic!("{}", str::from_utf8(&output.stderr).unwrap());
    }
}

fn find_binary(stdout: &str) -> Option<Vec<u8>> {
    let start = stdout.find("Binary:")? + 8;
    Some(hex::decode(&stdout[start..stdout.len() - 1]).unwrap())
}

pub async fn deploy_and_call_verifiers2(sols_dir: &PathBuf, runs: Option<usize>, proof: &[u8], instance: &DefaultEmailVerifyPublicInput) {
    // // Wouldn't work :(
    // let (_, verifier_bytecode, _) = get_contract_artifacts(&sols_dir.join("Halo2Verifier.sol"), "Halo2Verifier", runs);
    // let (_, vk_bytecode, _) = get_contract_artifacts(&sols_dir.join("VerifyingKey.sol"), "Halo2VerifyingKey", runs);

    let mut verifier_solidity = Vec::new();
    let mut vk_solidity = Vec::new();
    File::open(sols_dir.join("Halo2Verifier.sol")).unwrap().read_to_end(&mut verifier_solidity).unwrap();
    File::open(sols_dir.join("VerifyingKey.sol")).unwrap().read_to_end(&mut vk_solidity).unwrap();
    let verifier_bytecode = compile_solidity(verifier_solidity);
    let vk_bytecode = compile_solidity(vk_solidity);

    let mut evm = Evm::new();
    dbg!(&evm.evm.env.cfg);
    let verifier_address = evm.create(verifier_bytecode.to_vec());
    dbg!(verifier_address);
    let vk_address = evm.create(vk_bytecode.to_vec());
    dbg!(vk_address);

    let (gas_cost, output) = evm.call(
        verifier_address,
        halo2_solidity_verifier::encode_calldata(vk_address.0.into(), proof, &instance.instances::<bn256::Fr>()),
    );
    assert_eq!(revm::primitives::U256::from_be_bytes::<0x20>(output.try_into().unwrap()), revm::primitives::U256::from(1));
    println!("Gas cost: {gas_cost}");
}

pub async fn deploy_and_call_verifiers(sols_dir: &PathBuf, runs: Option<usize>, proof: &[u8], instance: &DefaultEmailVerifyPublicInput) {
    let anvil = setup_eth_backend().await;
    let client = setup_eth_client(&anvil).await;
    let runs = runs.unwrap_or(1);
    let config_params = default_config_params();
    let mut gas_sum = U256::zero();
    // let (base_addr, gas) = deploy_verifier_base_and_funcs(&client, sols_dir, runs).await;
    // gas_sum += gas;

    let (vk_addr, gas) = deploy_verifier_via_solidity(&client, sols_dir.join("VerifyingKey.sol"), "Halo2VerifyingKey", (), None).await;
    gas_sum += gas;
    let (halo2_addr, gas) = deploy_verifier_via_solidity(&client, sols_dir.join("Halo2Verifier.sol"), "Halo2Verifier", (), None).await;
    gas_sum += gas;
    let max_header_bytes = config_params.header_config.as_ref().unwrap().max_variable_byte_size;
    let max_body_bytes = config_params.body_config.as_ref().unwrap().max_variable_byte_size;
    let (email_verifier, gas) = deploy_verifier_via_solidity(
        &client,
        sols_dir.join("EmailVerifier.sol"),
        "EmailVerifier",
        (
            // Token::Address(base_addr),
            Token::Address(vk_addr),
            Token::Address(halo2_addr),
            Token::Uint(U256::from(max_header_bytes)),
            Token::Uint(U256::from(max_body_bytes)),
        ),
        Some(runs),
    )
    .await;
    gas_sum += gas;
    println!("total deploy gas {}", gas_sum);
    println!("address {:?}", Address::from(email_verifier));

    let verifier = EmailVerifier::new(email_verifier, client.clone());
    let instance = encode(&[
        Token::Uint(U256::from_str_radix(&instance.header_hash_commit, 10).unwrap()),
        Token::Uint(U256::from_str_radix(&instance.public_key_hash, 10).unwrap()),
        Token::Array(instance.header_substrs.iter().map(|s| Token::String(s.clone())).collect_vec()),
        Token::Array(instance.header_starts.iter().map(|idx| Token::Uint(U256::from(idx.clone()))).collect_vec()),
        Token::Array(instance.body_substrs.iter().map(|s| Token::String(s.clone())).collect_vec()),
        Token::Array(instance.body_starts.iter().map(|idx| Token::Uint(U256::from(idx.clone()))).collect_vec()),
    ]);
    let proof = Bytes::from(proof.to_vec());
    let fn_call = verifier.verify_email(Bytes::from(instance.clone()), proof.clone()).gas(10000000);
    let result = fn_call.send().await.unwrap();
    let recepit = result.await.unwrap().unwrap();
    println!("gas used {:?}", recepit.gas_used);

    // let call = verifier.method::<_, ()>("verifyEmail", (Bytes::from(instance.clone()), proof.clone())).unwrap();
    // println!("estimated gas {:?}", call.estimate_gas().await.unwrap());
    // drop(anvil);
}

async fn deploy_verifier_base_and_funcs(client: &EthersClient, sols_dir: &PathBuf, runs: usize) -> (Address, U256) {
    let deploy_params =
        serde_json::from_reader::<_, DeployParamsJson>(File::open(&sols_dir.join("deploy_params.json")).expect(&format!("deploy_params.json in {:?} cannot open", sols_dir)))
            .expect(&format!("fail to convert deploy_params.json in {:?}", sols_dir));
    let mut func_addrs = vec![];
    let mut gas_sum = U256::zero();
    for idx in 0..deploy_params.num_func_contracts {
        let (func_addr, gas) = deploy_verifier_via_solidity(client, sols_dir.join(format!("VerifierFunc{}.sol", idx)), &format!("VerifierFunc{}", idx), (), Some(runs)).await;
        gas_sum += gas;
        func_addrs.push(Address::from(func_addr));
    }
    let base_args = (func_addrs, U256::from(deploy_params.max_transcript_addr));
    let (base_addr, gas) = deploy_verifier_via_solidity(client, sols_dir.join("VerifierBase.sol"), "VerifierBase", base_args, Some(runs)).await;
    gas_sum += gas;
    (base_addr, gas_sum)
}

// original: https://github.com/zkonduit/ezkl/blob/main/src/eth.rs#L89-L103
async fn deploy_verifier_via_solidity<T: Tokenize>(
    client: &EthersClient,
    sol_code_path: PathBuf,
    contract_name: &str,
    args: T,
    runs: Option<usize>,
) -> (ethers::types::Address, U256) {
    let (abi, bytecode, runtime_bytecode) = get_contract_artifacts(&sol_code_path, contract_name, runs);
    let factory = get_sol_contract_factory(abi.clone(), bytecode, runtime_bytecode, client.clone());
    let (contract, receipt) = factory
        .deploy(args)
        .expect("invalid deploy params")
        .send_with_receipt()
        .await
        .expect("failed to deploy the factory");
    println!("solidity code path: {:?}", &sol_code_path);
    println!("gas used: {:?}", receipt.gas_used);
    (contract.address(), receipt.gas_used.unwrap())
}

// original: https://github.com/zkonduit/ezkl/blob/main/src/eth.rs#L558-L578
pub fn get_contract_artifacts(sol_code_path: &PathBuf, contract_name: &str, runs: Option<usize>) -> (Abi, Bytes, Bytes) {
    assert!(sol_code_path.exists(), "sol_code_path {:?} does not exist", sol_code_path);
    // Create the compiler input, enabling the optimizer and setting the optimzer runs.
    let input: CompilerInput = if let Some(r) = runs {
        let mut i = CompilerInput::new(&sol_code_path).expect("invalid compiler input")[0].clone().optimizer(r);
        i.settings.optimizer.enable();
        i
    } else {
        CompilerInput::new(&sol_code_path).expect("invalid compiler input")[0].clone()
    };
    let input = input.evm_version(EvmVersion::Paris);
    let compiled = Solc::default().compile(&input).unwrap();
    // println!("compiled {:?}", compiled);
    let (abi, bytecode, runtime_bytecode) = compiled
        .find(contract_name)
        .expect(&format!("could not find contract {} in {:?}", contract_name, &sol_code_path))
        .into_parts_or_default();
    dbg!(bytecode.len());
    dbg!(runtime_bytecode.len());
    (abi, bytecode, runtime_bytecode)
}

fn get_sol_contract_factory<M: 'static + Middleware>(abi: Abi, bytecode: Bytes, runtime_bytecode: Bytes, client: Arc<M>) -> ContractFactory<M> {
    const MAX_RUNTIME_BYTECODE_SIZE: usize = 24577;
    let size = runtime_bytecode.len();
    println!("bytecode size {}", size);
    if size > MAX_RUNTIME_BYTECODE_SIZE {
        // `_runtime_bytecode` exceeds the limit
        panic!(
            "Solidity runtime bytecode size is: {:#?},
            which exceeds 24577 bytes limit.",
            size
        );
    }
    ContractFactory::new(abi, bytecode, client)
}
