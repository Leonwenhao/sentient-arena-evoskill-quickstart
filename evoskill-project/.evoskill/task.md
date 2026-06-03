# Task

Answer questions about U.S. Treasury Bulletin financial data (the OfficeQA benchmark
used by Sentient Arena Challenge 1). Each question asks for a precise numeric value
that must be retrieved from the source documents and, usually, computed.

You have a corpus of pre-parsed monthly bulletins (`treasury_bulletin_YYYY_MM.txt`)
in the data directory. Retrieve with grep, extract the exact printed values, compute
in Python, and write ONLY the final answer.

## Examples
- "Total expenditures (in millions of nominal dollars) for U.S. national defense in calendar year 1940?" → `2602`
- "Geometric mean of the monthly outlays of the US judiciary, Jan 1984–Mar 1987, in millions, rounded to 3 dp?" → `81.406`

---

# Constraints

- Answers must mirror the requested **unit scale** ("in millions" → write the millions value).
- Output **only the final number** (plain decimal digits): no units, no `$`, no `%` sign needed, no scientific notation, no accounting parentheses (use a leading minus).
- Compute in **Python standard library only** — `numpy`/`scipy`/`statsmodels`/`pandas` are NOT installed at eval time.
- Do **not** use external APIs or the network — answer only from the provided documents.
- The scorer accepts answers within **1%** of the ground truth; round exactly as the question asks.
