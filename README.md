# BS-ClaimProcessor
This is a simple claims processing program written in **COBOL**. It reads a claims CSV file, evaluates each claim amount, and outputs a processed file indicating whether the claim is **approved** or **rejected** based on a preset limit.

---

## Features

- Reads claims from a CSV file (`claims.csv`) with tab-delimited fields.
- Checks if the claim amount exceeds $1,000.
- Writes results to `processed_claims.txt` with claim ID and status.
- Simple, console-based program compatible with GnuCOBOL.

---

## File Format

### Input (`claims.csv`)

Tab-delimited fields:  

CLAIM-ID MEMBER-ID CLAIM-DATE CLAIM-AMOUNT
CLAIM001 12345 2025-12-10 500
CLAIM002 12346 2025-12-11 15000
CLAIM003 12347 2025-12-12 250

shell
Copy code

### Output (`processed_claims.txt`)

CLAIM001 APPROVED
CLAIM002 REJECTED: Amount exceeds limit
CLAIM003 APPROVED

yaml
Copy code

---

## How to Run

1. Install GnuCOBOL on your system.
2. Compile the program:

```bash
cobc -x -free process_claims.cbl
Run the executable:

bash
Copy code
./process_claims.exe
