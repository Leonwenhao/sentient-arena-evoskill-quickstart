---
name: officeqa-playbook
description: USE FOR EVERY OfficeQA / Treasury-Bulletin question. The grounded numeric-reasoning playbook that won highest-accuracy in Sentient Arena Cohort 0 — stdlib-only computation, corrected statistical formulas, scorer-format discipline, and retrieval/unit/fiscal-year traps. EvoSkill improves on top of this.
---

# OfficeQA Playbook (Arena Cohort-0 winning baseline)

A grounded reasoning agent for U.S. Treasury Bulletin Q&A. The corpus is ~700
pre-parsed markdown files at the data dir, one per monthly bulletin
(`treasury_bulletin_YYYY_MM.txt`). Answers are scored at **1% numeric tolerance**.

## IRON RULES — violating these scores ZERO

1. **Write the final answer to the answer file in EVERY code block.** A rough answer beats an empty file. End each Python block with `with open(ANSWER_PATH,'w') as f: f.write(str(result))`.
2. **ALL math in Python, STANDARD LIBRARY ONLY** (`import statistics, math`). The eval container has **no numpy / scipy / statsmodels / pandas and no pip** — importing them crashes the run and forces error-prone hand math. Python 3.12 stdlib already has `statistics.geometric_mean / fmean / linear_regression / correlation / pstdev / stdev`.
3. **After writing the final answer, STOP.** Do not re-verify or re-search. Overwriting a correct answer with a "verification" is a top cause of wrong answers. Only reopen a file on a concrete unit/date/cell error.

## WORKFLOW

1. **Read the question.** Identify: exact metric, period, requested units, how many values, and whether it says "reported IN" a specific bulletin.
2. **Retrieve with grep, never scroll.** `grep -l "metric" <corpus>/treasury_bulletin_YYYY_*.txt` → `grep -n -i "metric" FILE` → `sed -n 'A,Bp' FILE`. For multi-year questions, grep the LATEST year first for a retrospective summary table (one table beats 12 files).
3. **Extract raw**, exactly as printed. Trace the full hierarchical column path. Check units in title/header/column/footnote. Verify fiscal vs calendar year.
4. **Compute in stdlib Python.** Write the answer file in every block.
5. **Format** the bare number per the OUTPUT contract.

## EXTRACTION DISCIPLINE (prevents wrong-cell / wrong-year / missing-value)

Before computing, print one trace line per value: `<column path> | <raw value> | <unit> | <year>`, then assert `len(found) == expected` and re-extract if not. NEVER compute from a partial set — a missing value is a wrong answer. Try synonyms (outlays↔expenditures, receipts↔revenue, defense↔military). Data for year X often appears in the X+1 or X+2 bulletin.

## NAMED FORMULAS — corrected, stdlib-only (use exactly these)

```python
import statistics, math
geomean   = statistics.geometric_mean(vals)              # positive LEVELS, not % returns
lr = statistics.linear_regression(x, y); slope, intercept = lr.slope, lr.intercept
pred      = slope * x_target + intercept
r2        = statistics.correlation(x, y) ** 2
cv        = statistics.pstdev(vals) / statistics.fmean(vals)         # population unless "sample"
g         = [math.log(vals[i]/vals[i-1]) for i in range(1, len(vals))]
cv_log    = statistics.pstdev(g) / statistics.fmean(g)              # CV of YoY log growth
cagr      = (end/start) ** (1/(end_year - start_year)) - 1          # n = PERIODS, not #points
pct_pt    = new_pct - old_pct                                       # percentage POINTS, not % change
sym       = 2*(V2 - V1)/(V2 + V1)                                   # symmetric growth ...
fisher    = (V2 - V1)/math.sqrt(V1*V2)                              # ... != Fisher (distinct!)
r = sorted(returns); k = max(1, math.ceil(len(r)*alpha)); es = sum(r[:k])/k   # CVaR/ES; alpha from Q
mu = statistics.fmean(v); theil = statistics.fmean([(x/mu)*math.log(x/mu) for x in v])   # x>0
n = len(v); mu = statistics.fmean(v)
gini = (sum(abs(a-b) for a in v for b in v)/(n*n)) / (2*mu)         # any N; NOT abs(x1-x2)/(x1+x2)
hhi  = sum(s*s for s in shares)                                     # fractions; *10000 only if "points"
boxcox = math.log(x) if lam == 0 else (x**lam - 1)/lam             # GIVEN lambda; do not re-estimate
```

These corrections matter: the naive CVaR returns NaN whenever `int(n*alpha)==0` (e.g. 10 yearly returns at 95%); the naive 2-value Gini is 2× too large; symmetric and Fisher growth are NOT equal. Parameters (lambda, alpha, ddof, smoothing) ALWAYS come from the question text — never hardcode. "Geometric mean of VALUES" uses levels directly; "geometric annual RATE" uses `(end/start)**(1/n)-1`. For HP-filter / polynomial / any linear system, solve by hand with Gaussian elimination (no numpy); read the smoothing parameter from the question (annual data is often 6.25 or 100, never 1600).

## UNIT CONVERSION (#1 error pattern)

Tables show "thousands" or "millions" (check title, header, column, footnote — all four). Question "nominal dollars": thousands → ×1,000; millions → ×1,000,000. "in millions" + millions table → none; + thousands → ÷1,000. "in billions" + millions → ÷1,000. Parenthetical `(234)` = NEGATIVE. `n.a.`/`---` = not available, not zero.

## FISCAL vs CALENDAR YEAR

Before 1976: FY = Jul 1–Jun 30 (FY1975 = Jul 1974–Jun 1975); transition quarter Jul–Sep 1976. After 1976: FY = Oct 1–Sep 30 (FY2024 = Oct 2023–Sep 2024). "Calendar year" ≠ "fiscal year" — for CY you may sum individual months.

## DOMAIN TRAPS

"reported IN February 1938" → open `treasury_bulletin_1938_02.txt` ONLY; never substitute a retrospective table. "Capital"/"Paid-in capital" = original appropriation; "Total capital"/"Fund balance" = capital + earnings (use TOTAL unless "paid-in"). "Net receipts" = total − refunds. "Gross debt" includes intragovernmental; "Debt held by public" excludes it. "Outlays" ≠ "Expenditures" in scope. Hierarchical headers flatten as "Parent - Child"; trace the FULL path. If the question omits "reported in", prefer the later revised figure.

## OUTPUT (verified against the 1% scorer)

The final answer is **plain decimal digits only**: NEVER scientific notation (`9.3585e11` scores 0 — write `935851121560`); negatives as a leading minus (`-184.143`), NEVER accounting parens (`(184.143)` scores 0); MIRROR the requested unit scale ("in millions" → write `36080`, not `36080000000`); round exactly as asked; percent value → write `12.34` not `0.1234`; never write `NaN`/`inf`; multi-part `[a, b]` → all parts present, each within 1%.
