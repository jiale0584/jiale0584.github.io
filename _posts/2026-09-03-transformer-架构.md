---
{ layout: post, date: 2026-09-03 20:13:32, giscus_comments: false, related_posts: false, toc: { sidebar: left }, title: Transformer 架构复习, description: "", categories: [ LLM ], tags: [], lang: zh }
---

复习的流程主要是通过一些重要的图，对这些图进行讲解，然后顺带回忆知识。

我们先开始我们的第一张图。

# 一、经典 Encoder–Decoder Transformer

![image](/assets/img/posts/transformer-u67b6-u6784/image.png)

这张图里左边的是编码器，右边是解码器。我们先从左边的编码器开始。实际上，现代的 LM 基本上都是支持用单独的解码器。

## 1.输入嵌入
首先从 Inputs 开始。输入首先经过**输入嵌入（Input Embedding）**。Tokenizer，也就是分词器，已经把句子变成 Token ID，但 Token ID 本身只是整数编号，所以 Embedding 会把每个 Token 变成一个 d 维连续向量。

## 2.位置编码
但是 Embedding 本身没有位置信息，所以还要加**位置编码（Positional Encoding）**。原始 Transformer 使用的是正弦位置编码（Sinusoidal Positional Encoding），即给不同位置加入不同的 sin/cos 模式。这样模型才能区分“猫追狗”和“狗追猫”。

## 3.多头自注意力
接下来进入**多头自注意力（Multi-Head Self-Attention）**。

先解释自注意力。这个东西功能上的准确的说法是：对于每一个 Token，Self-Attention 都会计算它应该从序列中其他 Token 读取多少信息，然后把这些信息加权汇总，形成一个上下文化的新表示。

用一种不怎么严格的表述来说，可以这样来理解：我们都知道，对于一个词而言，它所表达的意思不仅要看这个词的本意，还需要看它在一个句子里的位置，也就是它的含义核心是通过与其他词的差异构成的。所以这个自注意力的功能就是让每个 Token 的表示包含了一部分整个句子的含义。

而所谓多头，就是同时使用多组不同的 $W_Q$、$W_K$、$W_V$ 进行这样的 Attention 计算。不同的 Head 因此可以学到不同的 Token 关系模式，最后再把各个 Head 得到的信息拼接起来。可以简单理解成“一个 Head 负责语法、另一个 Head 负责语义”。不过更准确的说法是：不同 Head 提供了多套不同的信息检索方式。

我们再用公式来进行表达：

$$
Q = XW_Q,\qquad K = XW_K,\qquad V = XW_V
$$


对于具体的计算，我们把输入序列当前的隐藏表示记作 $X$ 。Self-Attention 会通过三个不同的线性变换，把同一个 $X$ 分别变成 Query、Key 和 Value。

这里的 Query、Key 和 Value 并不是三份不同的输入，而是同一份 Token 表示经过三个不同的投影以后承担了三种不同的作用。对于第 $i$ 个 Token 来说，它的 Query 会和序列中每个 Token 的 Key 进行匹配，由此决定它应该从各个 Token 中读取多少信息；真正被读取并汇总的内容，则来自对应的 Value。

$$
\operatorname{Attention}(Q,K,V)
=
\operatorname{softmax}
\left(
\frac{QK^{\top}}{\sqrt{d_k}}
\right)V
$$

如果序列中有 $n$ 个 Token，那么它会得到一个 $n\times n$ 的矩阵，其中第 $i$ 行第 $j$ 列就是第 $i$ 个 Token 的 Query 和第 $j$ 个 Token 的 Key 的匹配程度。经过 Softmax 后，这些匹配分数被转换成注意力权重，再用这些权重对 Value 做加权求和，于是每个 Token 最终都会得到一个融合了上下文信息的新表示。

## 4.残差连接和层归一化

### 4.1正文

先说 Add，也就是**残差连接（Residual Connection）**。经过 Self-Attention 后，我们会得到一份根据上下文重新计算出来的信息，但这份结果本身并不会自动保留原来 Token 表示中的全部信息。

比如说，假设进入 Self-Attention 之前的表示是 $X$，Attention 计算出的结果是 $A$：$$
A=\operatorname{MultiHeadSelfAttention}(X)
$$

而这个 $A$ 实质上只是 $X$ 所需要增加的信息。而这部分相对于原状态多出来的信息，就叫残差。

残差连接其实就是把这份信息再加回原来的表示，也就是：

$$
\widetilde{X}
=
X+
\operatorname{MultiHeadSelfAttention}(X)
$$

残差连接还有另一个很重要的作用，就是让深层 Transformer 更容易训练。因为原来的 $X$ 有一条不经过 Attention 或 FFN 的直接路径一直向后传递，所以无论是前向的信息还是反向传播的梯度，都不必每一层都完全穿过复杂的子网络。这也是 Transformer 能够连续堆叠几十层甚至上百层的重要条件之一。

然后就是 Norm，也就是**层归一化（Layer Normalization, LayerNorm）**。它主要对每个 Token 的特征维度进行归一化，使不同层之间隐藏状态的数值尺度保持稳定，从而让深层网络更容易训练。

也就是说，这个操作完全就是为了计算上的方便。

另外，原始 Transformer 使用的是后归一化（Post-Layer Normalization, Post-LN），就是先做子层计算，再做残差相加，最后归一化。因此图中的整个 Add & Norm 实际上可以写成：

$$
X'
=
\operatorname{LayerNorm}
\left(
X+
\operatorname{MultiHeadSelfAttention}(X)
\right)
$$

而后来很多深层 Transformer 改成了 前归一化（Pre-LN）。就是先归一化，再让 Attention / FFN 计算，最后与原来的 X 做残差相加。

$$
Y=
X+
F\left(
\operatorname{LayerNorm}(X)
\right)
$$

***

### 4.2为什么现代模型通常更偏向 Pre-LN

先把 Attention 或 FFN 统一记作一个子层 $F$，隐藏状态记作 $x$。对于 Transformer 来说，$x$ 是高维向量，$F(x)$ 也是高维向量。因此一层网络对输入的导数不是一个普通标量，而是雅可比矩阵。

就是说：

$$
x=
\begin{bmatrix}
x_1\\
x_2\\
\vdots\\
x_d
\end{bmatrix}
\in\mathbb{R}^d
\qquad
F(x)=
\begin{bmatrix}
F_1(x)\\
F_2(x)\\
\vdots\\
F_d(x)
\end{bmatrix}
\in\mathbb{R}^d
\qquad
J_F(x)=
\begin{bmatrix}
\frac{\partial F_1}{\partial x_1} &
\frac{\partial F_1}{\partial x_2} &
\cdots &
\frac{\partial F_1}{\partial x_d}\\
\frac{\partial F_2}{\partial x_1} &
\frac{\partial F_2}{\partial x_2} &
\cdots &
\frac{\partial F_2}{\partial x_d}\\
\vdots & \vdots & \ddots & \vdots\\
\frac{\partial F_d}{\partial x_1} &
\frac{\partial F_d}{\partial x_2} &
\cdots &
\frac{\partial F_d}{\partial x_d}
\end{bmatrix}
$$


更具体地说，在 Transformer 里通常：

$$
X\in\mathbb{R}^{n\times d}
$$

其中 $n$ 是 Token 数，$d$ 是隐藏维度。严格来说，可以把它摊平成：

$$
\operatorname{vec}(X)\in\mathbb{R}^{nd}
$$

于是一个 Transformer 子层实际上可以看成：

$$
F:\mathbb{R}^{nd}\rightarrow\mathbb{R}^{nd}
$$

因此它的 Jacobian 从概念上是：

$$
J_F\in\mathbb{R}^{nd\times nd}
$$

***
现在先看原始 Transformer 使用的 后归一化（Post-Layer Normalization, Post-LN）：

$$ y = \operatorname{LN}\bigl(x+F(x)\bigr). $$

令 $z=x+F(x)$，那么第一步 $x\rightarrow z$ 的 Jacobian 是



$$ \frac{\partial z}{\partial x} = I+J_F(x). $$


接下来还有一层

$$ y=\operatorname{LN}(z), $$

它的 Jacobian 记作 $J_{\mathrm{LN}}(z)$。根据链式法则，这一整个 Post-LN 子层的 Jacobian 就是

$$ J_{\mathrm{Post}} = J_{\mathrm{LN}}(z) \bigl(I+J_F(x)\bigr). $$


如果模型只有一层，这当然没什么问题。但 Transformer 会连续堆很多层。假设一共有 $L$ 层，那么从最上层把梯度传回最底层时，会不断乘上每一层对应的 Jacobian：

$$ J_{\text{total}} = J_{\mathrm{Post}}^{(L)} J_{\mathrm{Post}}^{(L-1)} \cdots J_{\mathrm{Post}}^{(1)} $$

把每一层的具体形式代进去，就是：

$$ J_{\text{total}} = J_{\mathrm{LN}}^{(L)} \left(I+J_F^{(L)}\right) J_{\mathrm{LN}}^{(L-1)} \left(I+J_F^{(L-1)}\right) \cdots J_{\mathrm{LN}}^{(1)} \left(I+J_F^{(1)}\right) $$

这时候问题就很直观了：梯度从第 $L$ 层一路传回第 $1$ 层，每经过一层，都必须再乘一次 $J_{\mathrm{LN}}$ 和 $I+J_F$。这些矩阵都可能改变梯度的大小和方向，所以层数越多，这些变化就会不断累积。

如果为了直观，暂时把每个 Jacobian 想成一个普通的缩放系数，那么问题就更明显了。假设每层平均把梯度缩小到原来的 $0.9$，经过 $100$ 层后：

$$ 0.9^{100}\approx 2.7\times10^{-5} $$

梯度几乎消失；如果每层平均放大到 $1.1$，那么：

$$ 1.1^{100}\approx 1.4\times10^4 $$

梯度就会爆炸。

真实情况当然不是一个标量，而是矩阵，所以不同方向上的梯度会被不同程度地缩放、旋转甚至削弱。但核心问题完全一样：Post-LN 的梯度必须层层穿过这些变换，没有一条可以一路绕开它们的直接通道。
***

再看 前归一化（Pre-Layer Normalization, Pre-LN）：

$$ y = x+ F\bigl(\operatorname{LN}(x)\bigr). $$

令

$$ u=\operatorname{LN}(x), $$

那么这一层的 Jacobian 是

$$ J_{\mathrm{Pre}} = I+ J_F(u)J_{\mathrm{LN}}(x). $$

注意这里和 Post-LN 的结构差别：

$$ \text{Post-LN:}\qquad J_{\mathrm{LN}} \bigl(I+J_F\bigr) $$

而

$$ \text{Pre-LN:}\qquad I+ J_FJ_{\mathrm{LN}}. $$

这个 $I$ 的位置极其重要。Pre-LN 中，LayerNorm 和子层 $F$ 全部位于残差分支上，而原始的 $x$ 可以直接沿着残差主干进入下一层。因此即使复杂分支$J_FJ_{\mathrm{LN}}$在某一层非常小，仍然有

$$ J_{\mathrm{Pre}}\approx I. $$

也就是说，这一层至少不会因为 Attention、FFN 或 LayerNorm 分支的 Jacobian 很小，就把梯度完全截断。当然，如果残差分支的 Jacobian 很大，仍可能导致梯度放大甚至爆炸。

另外，当连续堆叠很多 Pre-LN 层时，总 Jacobian 会包含很多 $I+A_l$形式的因子，其中

$$ A_l = J_{F_l}J_{\mathrm{LN},l}. $$

把这些乘积展开时，其中始终存在一项

$$ I\cdot I\cdots I=I. $$

这对应的就是一条从高层一直通向低层的恒等梯度路径（Identity Gradient Path）：梯度不必每一层都经过 Attention、FFN 和 LayerNorm 的复杂 Jacobian 才能继续向下传播。

所以 Pre-LN 更稳定的核心并不是“LayerNorm 放前面以后数学上更好看”，而是：

Post-LN 中，即使有残差连接，残差主干在每一层末尾仍然必须经过 LayerNorm，因此不存在完全干净的恒等通路；Pre-LN 则把 LayerNorm 和子层计算放到残差支路上，让 $x$ 本身形成一条连续的恒等主干，从而使信息和梯度都更容易跨越很多层传播。

也正因为 Pre-LN 的最后一个操作通常只是残差相加，而不是 Norm，所以现代 Pre-LN Transformer 在所有 Block 结束以后通常还会额外补一个 Final LayerNorm 或 Final RMSNorm。

## 5.前馈神经网络

FFN 的作用是：对每一个 Token 当前已经获得的特征进行独立的非线性加工和重新组合。

经典 Transformer 中的 FFN 可以写成：

$$
\operatorname{FFN}(x)
=
W_2\,\sigma(W_1x+b_1)+b_2
$$

原始 Transformer 的隐藏维度是 $d_{\text{model}}=512$，而 FFN 的中间维度是 $d_{\text{ff}}=2048$，所以一个 Token 的表示会经历：512 → 2048 → 非线性激活 → 512

确实有一个“扩维再压回去”的过程，但扩维的目的不是解压，而是给模型提供一个更大的特征空间，让它能够进行更丰富的非线性变换。

## 6. 右移后的输出序列
我们现在来到了右边的解码器部分。


比如训练目标是：

`我 喜欢 猫 <EOS>`

但 Decoder 真正吃进去的输入不是这句话本身，而是：

`<BOS> 我 喜欢 猫`

二者上下对齐有：

| 位置         | 1       | 2  | 3  | 4       |
| ---------- | ------- | -- | -- | ------- |
| Decoder 输入 | `<BOS>` | 我  | 喜欢 | 猫       |
| 预测目标 Label | 我       | 喜欢 | 猫  | `<EOS>` |

也就是说，原来的目标序列：

`我  喜欢  猫  <EOS>`

拿来作为 Decoder 输入时，前面塞进一个 **BOS（Beginning of Sequence，序列开始符）**：

`<BOS>  我  喜欢  猫`

于是从视觉上看，Decoder 输入与预测目标这两个序列正好错开一个位置，因此通常称为 **右移（Shift Right）**。


真正关键的不是“向右移动”这个动作本身，而是它制造出了这样一个训练关系：

`<BOS>` → 预测“我”
`<BOS> 我` → 预测“喜欢”
`<BOS> 我 喜欢` → 预测“猫”
`<BOS> 我 喜欢 猫` → 预测 `<EOS>`



右移之后的这些 Token 同样先经过 Embedding，再加入 Positional Encoding，然后进入 Decoder 的第一层。

## 7. 掩码

Decoder 的第一层 Attention 和 Encoder 很相似，但多了一个非常重要的限制：因果掩码（Causal Mask）。

训练时，我们其实一次性已经拿到了完整的目标序列。如果没有 Mask，那么模型在预测当前位置时，就可能直接看到后面的真实答案，这样训练任务本身就失去意义了。

因此 Decoder 使用：

$$
\operatorname{Attention}(Q,K,V)
=
\operatorname{softmax}
\left(
\frac{QK^\top}{\sqrt{d_k}}+M
\right)V
$$

其中 $M$ 是因果掩码矩阵。对于第 $i$ 个位置：

$$
M_{ij}
=
\begin{cases}
0, & j\le i,\\
-\infty, & j>i.
\end{cases}
$$

未来位置被加上 $-\infty$ 以后，经过 Softmax，其注意力权重就变成 0。

所以第 $i$ 个 Token 只能看到它自己和它之前的 Token，无法看到未来。


## 8.多头交叉注意力

我们知道，最原始的 Transform ，它的目的就是为了一个特定的功能，也就是机器翻译。而对于机器翻译这种任务，只知道已经生成的目标文本显然还不够，Decoder 还必须知道原始输入在说什么。

于是 Cross-Attention 让 Decoder 去读取 Encoder 的最终输出。

这里和 Self-Attention 最大的区别，在于 $Q$、$K$、$V$ 的来源不同。

Self-Attention 中：

Q、K、V 都来自同一组 hidden states。

而 Cross-Attention 中：

Q 来自 Decoder，
K 和 V 来自 Encoder。

可以写成：

$$
\operatorname{CrossAttention}
\left(
Q_{\mathrm{dec}},
K_{\mathrm{enc}},
V_{\mathrm{enc}}
\right)
=
\operatorname{softmax}
\left(
\frac{
Q_{\mathrm{dec}}K_{\mathrm{enc}}^\top
}{
\sqrt{d_k}
}
\right)
V_{\mathrm{enc}}
$$

比如 Encoder 输入的是：

The cat is sleeping.

Decoder 已经生成：

那只

现在 Decoder 当前的 hidden state 会形成 Query，然后去和 Encoder 中所有 Token 的 Key 进行匹配。如果当前最需要的是 cat 的信息，那么对应位置会得到更高的 Attention 权重，随后从那个位置的 Value 中读取更多信息。

所以 Cross-Attention 的功能可以非常直接地理解成：

**Decoder 根据自己当前的生成状态，动态地去输入序列里寻找当前最需要的信息。**

而且 Cross-Attention 不需要 Causal Mask，因为 Encoder 处理的是已经完整给出的输入序列。Decoder 可以查看输入中的任何位置，真正不能偷看的只是未来的输出 Token。

因此一个 Decoder Layer 实际上完成了三件核心事情：先通过 Masked Self-Attention 整理已经生成的目标前文，再通过 Cross-Attention 从 Encoder 中读取当前需要的输入信息，最后通过 FFN 对这些融合后的特征进行非线性加工。


## 9. Linear 和 Softmax

经过所有 Decoder Layer 之后，我们最终得到的是 hidden state，但模型真正需要输出的是词表中的某一个 Token。

因此要经过一个 线性输出层（Linear Output Layer）

比如如果最终 hidden state 是 $h\in\mathbb{R}^d$，词表大小为 $|V|$，那么 Linear 会把它从隐藏空间映射到词表空间：

$$
z=W_{\mathrm{vocab}}h+b
$$

其中：

$$
z\in\mathbb{R}^{|V|}
$$

所以词表中的每一个 Token 都得到一个原始分数。这个分数就是 Logit。

Logit 本身还不是概率，因此最后再经过 Softmax：

$$
P(x_{t+1}=v_i\mid x_{\le t})
=
\frac{\exp(z_i)}
{\sum_j\exp(z_j)}
$$

这样就得到整个词表上的概率分布。

比如当前上下文是：我今天晚上想吃

模型可能得到：饭：0.31，面：0.24，火锅：0.17，……

于是模型再根据这个概率分布选择或采样下一个 Token。

所以实质上通过 Linear 就是得到的向量对应到词表空间上，然后通过 Softmax 都到后面会出现的词的种种概率，而最终我们会选出概率最大的那个进行输出。

# 二、仅解码器 Transformer 

![image](/assets/img/posts/transformer-u67b6-u6784/image-2.png)

前面那张图已经讲过很多重要的概念，这张图就主要讲一下这图与之前那张图的变化。

最核心的变化其实只有一句话：

**原始 Transformer 把“读取输入”和“生成输出”分给 Encoder 与 Decoder 两套网络；Decoder-only 则把输入和输出统一成一条 Token 序列，只保留一套带因果约束的 Decoder。**

## 1.没有 Encoder 和 Cross-Attention 

原始 Transformer 中，Decoder 每一层有三块核心计算：Masked Self-Attention、Cross-Attention 和 FFN。其中 Cross-Attention 的作用是让 Decoder 用自己的 Query 去读取 Encoder 提供的 Key 和 Value。

但 Decoder-only 中根本不存在 Encoder，所以也不存在：

$$
Q_{\mathrm{dec}},K_{\mathrm{enc}},V_{\mathrm{enc}}
$$

这种跨两套网络的信息交换。

整个模型只有一条序列。例如用户输入：“法国的首都是”。那么模型要继续生成：“巴黎”。但它并不会先把“法国的首都是”送进 Encoder，再让 Decoder 去读取 Encoder；而是直接把所有已经出现的 Token 放在同一条序列里：

$$
x_1,x_2,\ldots,x_n
$$

然后计算：

$$
P(x_{n+1}\mid x_{\leq n})
$$

所以 Decoder-only 做的事情从根本上就变成了**根据当前已经出现的全部 Token，预测下一个 Token。**

这也是为什么现代 LLM 可以把翻译、问答、摘要、代码生成等很多任务统一成 Prompt + Completion 的形式，而不再需要专门的 Encoder。

---

## 2.Self-Attention 实际上仍然是 Causal Self-Attention

这一点这张图画得有点容易误导。它里面写的是 **Multi-Head Self-Attention**，但对于 GPT 风格的 Decoder-only 模型，这里实际上仍然必须是因果自注意力（Causal Self-Attention）。

也就是原始 Decoder 里的 Masked Self-Attention。

公式仍然是：

$$
\operatorname{Attention}(Q,K,V)
=
\operatorname{softmax}
\left(
\frac{QK^\top}{\sqrt{d_k}}+M
\right)V
$$

其中因果掩码 $M$ 保证第 $i$ 个位置只能看到：

$$
x_1,x_2,\ldots,x_i
$$

而不能看到 $x_{i+1},x_{i+2},\ldots$。

所以 Decoder-only 并不是“把 Mask 去掉的 Decoder”，恰恰相反：**它把 Encoder 和 Cross-Attention 去掉了，但把 Decoder 最核心的因果 Self-Attention 完整保留下来。**

而且它所有层都遵守这个因果约束。

---

## 3.输入和输出不再是两套序列

这个变化其实比“少了一个 Encoder”更重要。

原始机器翻译 Transformer 有：

$$
\text{source sequence}
$$

和：

$$
\text{target sequence}
$$

例如英文在 Encoder，中文在 Decoder。

而 Decoder-only 里，Prompt 和模型输出被拼在同一条序列上。例如：

“Translate to Chinese: The cat is sleeping. → 猫正在睡觉。”

训练时整条序列都可以放进去，但 Causal Mask 会保证每个位置只能利用前面的内容预测下一个 Token。

所以训练目标统一成：

$$
P(x_1,x_2,\ldots,x_T)
=
\prod_{t=1}^{T}
P(x_t\mid x_{<t})
$$

这就是 **自回归语言建模（Autoregressive Language Modeling）**。

原始 Encoder–Decoder 还是“输入序列 → 输出序列”；Decoder-only 则进一步统一成了：

**一切都是 Token 序列的延续。**

---

## 4.Pre-Norm，而不是Post-Norm

这个之前说过了。


## 5.单独加一个 Final LayerNorm

因为一个 Pre-Norm Block 的最后一步是：

$$
X_{\text{out}}
=
X+
F(\operatorname{Norm}(X))
$$

也就是说，最后完成的是 Residual Add，而不是 Norm。

所以当连续 $L$ 个 Block 全部结束以后，最终 residual stream 还需要统一再做一次归一化：

$$
H_{\mathrm{final}}
=
\operatorname{LN}(H_L)
$$

这就是图中的 **Final LayerNorm**。

如果是现代 Llama 一类模型，这里通常更准确地说是 **Final RMSNorm（最终均方根归一化）**，因为它们很多已经不用经典 LayerNorm，而使用 RMSNorm。这个后面再展开。


## 6.现代模型的变化

但现代 LLM 里的MLP通常已经不是原始 Transformer 那种简单的FFN。比如 Llama、Mistral 常使用 **SwiGLU（Swish-Gated Linear Unit）** 一类门控 MLP。

以及标准 MHA 也可能换成 GQA 或 MLA。

这个也是以后再展开。

最后从历史上看，这张图最值得抓住的是：**现代 Decoder-only LLM 是把原始 Transformer 大幅简化成了一条统一的自回归计算主线，然后再围绕这条主线不断优化 Attention、MLP、Norm、位置编码和 KV Cache。**
