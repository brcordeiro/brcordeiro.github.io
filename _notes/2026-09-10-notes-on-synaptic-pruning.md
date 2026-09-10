---
title: "Notes on Synaptic Pruning"
date: 2026-09-10
tags:
  - llm
  - neuroscience
  - model-compression
  - pruning
excerpt: "LLMs have been scaling exponentially in parameter count. The human brain does something smarter: it prunes. Notes on whether the neuroscience concept of synaptic pruning points toward a better path for AI."
---

The story of large language models over the last few years is essentially a story about growth. GPT-2 had 1.5B parameters. GPT-3 jumped to 175B. PaLM reached 540B. GPT-4 is estimated somewhere around 1.7T. The tacit assumption behind this trajectory, formalized in the Kaplan et al. (2020) scaling laws, is that intelligence scales with size: more parameters, more data, more compute, better performance. The Chinchilla paper (Hoffmann et al., 2022) complicated the picture somewhat, showing that most large models were severely *undertrained* relative to their size, and that a 70B model trained on 1.4T tokens could beat a 280B model, but the fundamental assumption stayed in place: bigger is a direction.

There's a biological counterexample worth taking seriously.

## The Brain Doesn't Only Grow

The human brain contains roughly 86 billion neurons and perhaps 100 trillion synaptic connections at its peak, but this peak is not in adulthood. It's in early childhood. Between ages 2 and 16, the brain systematically *eliminates* a large fraction of synapses, a process called **synaptic pruning**. In the prefrontal cortex, the region associated with planning and abstract reasoning, up to 50% of synaptic connections formed in early childhood are pruned by early adulthood.

This isn't a bug. The prevailing neuroscientific account is that pruning is how the brain specializes. The connections that survive are the ones that have been frequently activated, a Hebbian "use it or lose it" principle. Weaker, less-used connections are tagged (literally, with complement proteins like C1q and C3) and phagocytosed by microglia. The result is a more efficient, more specialized network that consumes less energy and runs faster while retaining the information it actually needs.

The key insight: **capability comes not just from adding connections, but from selectively removing the ones that don't contribute**.

## The LLM Pruning Literature

Researchers have been applying variants of this idea to neural networks since at least the 1990s (LeCun et al.'s "Optimal Brain Damage"), but it has become an active subfield for LLMs in the last few years, usually under the label of *structured pruning* or *sparse pruning*.

The analogy is imperfect in the standard literature. Most pruning work is purely engineering-motivated, concerned with reducing inference cost after training. But a few lines of work take the biological parallel more seriously:

**SynFlow** (Tanaka et al., 2020) explicitly invokes synaptic flow as a pruning saliency metric, measuring the total flow of gradient-like signals through each connection, analogous to how biological pruning is activity-dependent. Importantly, SynFlow can determine which parameters to prune *before training*, which mirrors how developmental pruning is guided by early spontaneous activity before an organism fully engages with its environment.

**Biological Inspiration for DL Regularization** (arxiv 2508.09330, 2025) goes further: it proposes a training-time regularization method that emulates activity-dependent, gradual connection elimination during learning. Unlike post-training pruning or standard dropout, it applies a competitive elimination process throughout training, closer in spirit to how real synaptic competition plays out developmentally.

**Functional Network Pruning** (arxiv 2508.05239, 2025) draws explicitly from fMRI analysis methodology. The authors treat an LLM as a "digital brain" and apply Independent Component Analysis (a standard tool for discovering functional networks in BOLD signals) to identify which neuron clusters are functionally coherent, then prune while preserving those clusters. The analogy to how neuroscientists identify and protect specialized cortical networks during brain surgery is direct.

**Junk DNA Hypothesis** (arxiv 2310.02277) offers an interesting counterpoint: even seemingly inert, low-magnitude weights in LLMs may carry latent capability for rare or difficult tasks. Pruning them causes irreversible, asymmetric degradation: hard tasks break first. This echoes arguments in developmental biology about why the brain doesn't prune everything, even connections that seem dormant: some are preserved as low-cost optionality.

## What the Analogy Gets Right (and Wrong)

The biological parallel is genuinely suggestive, not just metaphorical:

1. **Activity-dependent selection** maps cleanly to *gradient-based saliency*. Synapses survive if they carry useful signal; weights survive if they carry useful gradient. The mechanisms differ but the principle is the same.

2. **Developmental timing** matters biologically. Aggressive pruning before the network has learned its representations is harmful. This is consistent with the empirical observation that pruning LLMs before convergence tends to destroy capability, while post-training pruning can remove large fractions of weights with minimal loss.

3. **Specialization vs. generalization tradeoff**. Pruned brains are faster and more efficient but less plastic. Heavily pruned LLMs often perform well on the tasks seen during training but degrade on out-of-distribution inputs. The Junk DNA paper makes this sharp.

Where the analogy breaks down: the brain prunes continuously over years with rich feedback from real-world interactions. LLM pruning is mostly a one-shot post-training operation. There's no real equivalent to adolescent synaptic competition, the multi-year process where patterns of firing literally determine which connections survive into adulthood.

## The Bigger Question

The direction this points is not obviously "train giant models and then compress them." A more interesting hypothesis is that the right architecture would incorporate something like developmental pruning *during* pre-training: a curriculum where the model starts overparameterized, then progressively specializes as it processes more data, shedding connections that haven't proven useful. This is closer in spirit to what the brain actually does.

Whether this can be made computationally tractable at scale is unclear. The memory and compute overhead of maintaining a dynamically shrinking graph during training is non-trivial. But given that inference costs now dominate deployment economics, and that frontier models are becoming difficult to run outside of a handful of data centers, the question of whether there's a more brain-like path to capability seems worth taking seriously.

## Open Questions

1. Are there training dynamics (not just post-training metrics) that would tell us which weights are candidates for pruning early, before the full training run completes?

2. Can activity-dependent pruning during training actually improve generalization, as opposed to just maintaining it at a lower parameter count?

3. What is the right level of granularity for pruning in transformers? Individual weights (unstructured), attention heads, MLP neurons, entire layers? The neuroscience analogy suggests *connection-level* pruning, but this is the hardest to accelerate on modern hardware.

## References

- Kaplan, J., McCandlish, S., et al. (2020). *Scaling Laws for Neural Language Models.* arXiv:2001.08361.
- Hoffmann, J., Borgeaud, S., et al. (2022). *Training Compute-Optimal Large Language Models.* arXiv:2203.15556. (Chinchilla)
- LeCun, Y., Denker, J., & Solla, S. (1990). *Optimal Brain Damage.* NeurIPS.
- Tanaka, H., Kunin, D., et al. (2020). *Pruning Neural Networks Without Any Data by Iteratively Conserving Synaptic Flow.* NeurIPS. arXiv:2006.05467.
- Ma, X., et al. (2025). *Synaptic Pruning: A Biological Inspiration for Deep Learning Regularization.* arXiv:2508.09330.
- Chen, Y., et al. (2025). *Pruning Large Language Models by Identifying and Preserving Functional Networks.* arXiv:2508.05239.
- Zheng, C., et al. (2023). *Junk DNA Hypothesis: Pruning Small Pre-Trained Weights Irreversibly and Monotonically Impairs "Difficult" Downstream Tasks in LLMs.* arXiv:2310.02277.
- Faust, T. E., Gunner, G., & Bhatt, D. L. (2021). *Mechanisms governing activity-dependent synaptic pruning in the developing mammalian CNS.* Nature Reviews Neuroscience, 22, 657–673.
