use ark_std::{end_timer, start_timer};
use cfdkim::canonicalize_signed_email;
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use halo2_base::halo2_proofs::halo2curves::bn256::Bn256;
use halo2_base::halo2_proofs::plonk::ConstraintSystem;
use halo2_base::halo2_proofs::poly::commitment::Params;
use halo2_base::halo2_proofs::poly::kzg::commitment::ParamsKZG;
use halo2_base::halo2_proofs::{
    circuit::{Cell, Layouter, SimpleFloorPlanner},
    dev::MockProver,
    halo2curves::bn256::Fr,
    plonk::{Circuit, Column, Error, Instance},
};
use halo2_base::{
    gates::range::{RangeConfig, RangeStrategy::Vertical},
    utils::PrimeField,
    SKIP_FIRST_PASS,
};
use halo2_dynamic_sha256::Sha256DynamicConfig;
use halo2_regex::defs::RegexDefs;
use halo2_regex::vrm::DecomposedRegexConfig;
use halo2_regex::{defs::*, vrm::*, *};
use halo2_zk_email::regex_sha2::*;
use halo2_zk_email::utils::*;
use halo2_zk_email::*;
use rand::rngs::OsRng;
use rand::thread_rng;
use sha2::{self, Digest, Sha256};
use snark_verifier_sdk::evm::{encode_calldata, evm_verify, gen_evm_proof_shplonk, gen_evm_verifier_shplonk};
use snark_verifier_sdk::gen_pk;
use snark_verifier_sdk::halo2::aggregation::PublicAggregationCircuit;
use snark_verifier_sdk::halo2::gen_snark_shplonk;
use snark_verifier_sdk::CircuitExt;
use std::env::set_var;
use std::fs::File;
use std::io::Read;
use std::marker::PhantomData;
use std::path::Path;

#[macro_export]
macro_rules! impl_sha2_circuit {
    ($config_name:ident, $circuit_name:ident, $max_bytes_size:expr, $num_advice:expr, $num_lookup_advice:expr, $lookup_bits:expr, $num_bits_lookup:expr,$num_advice_columns:expr, $k:expr) => {
        #[derive(Debug, Clone)]
        struct $config_name<F: PrimeField> {
            sha256_config: Sha256DynamicConfig<F>,
            instance: Column<Instance>, // hash_instance: Column<Instance>,
                                        // masked_str_instance: Column<Instance>,
                                        // substr_ids_instance: Column<Instance>,
        }

        #[derive(Debug, Clone)]
        struct $circuit_name<F: PrimeField> {
            input: Vec<u8>,
            _f: PhantomData<F>,
        }

        impl<F: PrimeField> Circuit<F> for $circuit_name<F> {
            type Config = $config_name<F>;
            type FloorPlanner = SimpleFloorPlanner;

            fn without_witnesses(&self) -> Self {
                Self { input: vec![], _f: PhantomData }
            }

            fn configure(meta: &mut ConstraintSystem<F>) -> Self::Config {
                let range_config = RangeConfig::configure(
                    meta,
                    Vertical,
                    &[Self::NUM_ADVICE],
                    &[Self::NUM_LOOKUP_ADVICE],
                    Self::NUM_FIXED,
                    Self::LOOKUP_BITS,
                    0,
                    Self::K as usize,
                );
                let sha256_config = Sha256DynamicConfig::configure(meta, vec![Self::MAX_BYTES_SIZE], range_config.clone(), $num_bits_lookup, $num_advice_columns, false);
                // let inner = RegexSha2Config::configure(meta, Self::MAX_BYTES_SIZE, Self::SKIP_PREFIX_BYTES_SIZE, range_config, regex_defs);
                let instance = meta.instance_column();
                meta.enable_equality(instance);
                // let masked_str_instance = meta.instance_column();
                // meta.enable_equality(masked_str_instance);
                // let substr_ids_instance = meta.instance_column();
                // meta.enable_equality(substr_ids_instance);
                Self::Config {
                    // inner,
                    sha256_config,
                    instance, // hash_instance,
                              // masked_str_instance,
                              // substr_ids_instance,
                }
            }

            fn synthesize(&self, mut config: Self::Config, mut layouter: impl Layouter<F>) -> Result<(), Error> {
                let witness_time = start_timer!(|| format!("Witness calculation"));
                // config.inner.load(&mut layouter)?;
                config.sha256_config.range().load_lookup_table(&mut layouter)?;
                config.sha256_config.load(&mut layouter)?;
                let mut first_pass = SKIP_FIRST_PASS;
                // let mut hash_bytes_cell = vec![];
                // let mut masked_str_cell = vec![];
                // let mut substr_id_cell = vec![];

                layouter.assign_region(
                    || "regex",
                    |region| {
                        if first_pass {
                            first_pass = false;
                            return Ok(());
                        }
                        let ctx = &mut config.sha256_config.new_context(region);
                        let assigned_hash_result = config.sha256_config.digest(ctx, &self.input, None)?;
                        // let result = config.inner.match_and_hash(ctx, &mut config.sha256_config, &self.input)?;
                        config.sha256_config.range().finalize(ctx);
                        // hash_bytes_cell.append(&mut result.hash_bytes.into_iter().map(|byte| byte.cell()).collect::<Vec<Cell>>());
                        // masked_str_cell.append(&mut result.regex.masked_characters.into_iter().map(|character| character.cell()).collect::<Vec<Cell>>());
                        // substr_id_cell.append(&mut result.regex.all_substr_ids.into_iter().map(|id| id.cell()).collect::<Vec<Cell>>());
                        Ok(())
                    },
                )?;
                end_timer!(witness_time);
                // for (idx, cell) in hash_bytes_cell.into_iter().enumerate() {
                //     layouter.constrain_instance(cell, config.hash_instance, idx)?;
                // }
                // for (idx, cell) in masked_str_cell.into_iter().enumerate() {
                //     layouter.constrain_instance(cell, config.masked_str_instance, idx)?;
                // }
                // for (idx, cell) in substr_id_cell.into_iter().enumerate() {
                //     layouter.constrain_instance(cell, config.substr_ids_instance, idx)?;
                // }

                Ok(())
            }
        }

        impl<F: PrimeField> CircuitExt<F> for $circuit_name<F> {
            fn num_instance(&self) -> Vec<usize> {
                vec![0]
            }

            fn instances(&self) -> Vec<Vec<F>> {
                vec![vec![]]
            }
        }

        impl<F: PrimeField> $circuit_name<F> {
            const MAX_BYTES_SIZE: usize = $max_bytes_size;
            const NUM_ADVICE: usize = $num_advice;
            const NUM_FIXED: usize = 1;
            const NUM_LOOKUP_ADVICE: usize = $num_lookup_advice;
            const LOOKUP_BITS: usize = $lookup_bits;
            const K: u32 = $k;
        }
    };
}

impl_sha2_circuit!(BenchSha2Config1, BenchSha2Circuit1, 1024, 6, 1, 16, 16, 1, 17);

fn bench_sha2(c: &mut Criterion) {
    let mut group = c.benchmark_group("sha2 1024 bytes");
    group.sample_size(10);
    let email_bytes = {
        let mut f = File::open("./test_data/test_email2.eml").unwrap();
        let mut buf = Vec::new();
        f.read_to_end(&mut buf).unwrap();
        buf
    };
    let (input, _, _) = canonicalize_signed_email(&email_bytes).unwrap();
    let circuit = BenchSha2Circuit1::<Fr> { input, _f: PhantomData };
    let prover = MockProver::run(BenchSha2Circuit1::<Fr>::K, &circuit, vec![vec![]]).unwrap();
    assert_eq!(prover.verify(), Ok(()));
    let rng = thread_rng();
    let params = ParamsKZG::<Bn256>::setup(BenchSha2Circuit1::<Fr>::K, rng);
    let pk = gen_pk::<BenchSha2Circuit1<Fr>>(&params, &circuit, None);
    println!("app pk generated");
    let vk = pk.get_vk();
    let num_instance = vec![0];
    let verifier_yul = gen_evm_verifier_shplonk::<BenchSha2Circuit1<Fr>>(&params, &vk, num_instance, None);
    let proof = gen_evm_proof_shplonk(&params, &pk, circuit.clone(), vec![vec![]], &mut OsRng);
    evm_verify(verifier_yul, true, vec![vec![]], proof);
    group.bench_function("sha2", |b| b.iter(|| gen_evm_proof_shplonk(&params, &pk, circuit.clone(), vec![vec![]], &mut OsRng)));
}

#[ignore]
impl_sha2_circuit!(BenchSha2ClientConfig1, BenchSha2ClientCircuit1, 1024, 100, 1, 14, 2, 8, 15);
#[ignore]
const AGG_K: u32 = 20;
#[ignore]
fn bench_sha2_recursion(c: &mut Criterion) {
    let mut group = c.benchmark_group("sha2 1024 bytes");
    group.sample_size(10);
    set_var(VERIFY_CONFIG_KEY, "configs/agg_for_partial_bench.config");
    let email_bytes = {
        let mut f = File::open("./test_data/test_email2.eml").unwrap();
        let mut buf = Vec::new();
        f.read_to_end(&mut buf).unwrap();
        buf
    };
    let (input, _, _) = canonicalize_signed_email(&email_bytes).unwrap();
    let circuit = BenchSha2ClientCircuit1::<Fr> { input, _f: PhantomData };
    let rng = thread_rng();
    let agg_params = ParamsKZG::<Bn256>::setup(AGG_K, rng);
    let mut app_params = agg_params.clone();
    app_params.downsize(BenchSha2ClientCircuit1::<Fr>::K);
    let app_pk = gen_pk::<BenchSha2ClientCircuit1<Fr>>(&app_params, &circuit, None);
    println!("app pk generated");
    let snark = gen_snark_shplonk(&app_params, &app_pk, circuit, &mut OsRng, None::<&str>);
    let agg_circuit = PublicAggregationCircuit::new(&agg_params, vec![snark], false, &mut OsRng);
    let agg_pk = gen_pk::<PublicAggregationCircuit>(&agg_params, &agg_circuit, None);
    let agg_vk = agg_pk.get_vk();
    let verifier_yul = gen_evm_verifier_shplonk::<PublicAggregationCircuit>(&agg_params, &agg_vk, agg_circuit.num_instance(), None);
    let instances = agg_circuit.instances();
    let proof = gen_evm_proof_shplonk(&agg_params, &agg_pk, agg_circuit.clone(), instances.clone(), &mut OsRng);
    evm_verify(verifier_yul, true, instances.clone(), proof);
    group.bench_function("sha2", |b| {
        b.iter(|| gen_evm_proof_shplonk(&agg_params, &agg_pk, agg_circuit.clone(), instances.clone(), &mut OsRng))
    });
}

criterion_group!(benches, bench_sha2,);
criterion_main!(benches);
