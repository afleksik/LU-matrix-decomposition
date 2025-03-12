# LU Matrix Decomposition

## Overview
This script performs LU decomposition of a given square matrix stored in a CSV file. The decomposition results in two matrices: 
- **L (Lower triangular matrix)**
- **U (Upper triangular matrix)**

The script ensures that the diagonal elements of **L** are always **1**, making the decomposition unique. The script does not modify the input matrix.

## Usage
To run the script, use the following command:

```bash
./decomposition.sh input.csv lower.csv upper.csv accuracy
```

### Positional Arguments
1. `input.csv` - Path to the input matrix file in CSV format.
2. `lower.csv` - Path to the output **L** matrix in CSV format.
3. `upper.csv` - Path to the output **U** matrix in CSV format.
4. `accuracy` - Number of decimal places for the output matrices.

### Example
#### Input File (`input.csv`)
```
3,1,2
4,13,12
7,20,103
```
#### Running the Script
```bash
./decomposition.sh input.csv lower.csv upper.csv 2
```
#### Output Files
##### `lower.csv`
```
1.00,0.00,0.00
1.33,1.00,0.00
2.33,1.51,1.00
```
##### `upper.csv`
```
3.00,1.00,2.00
0.00,11.67,9.33
0.00,0.00,84.20
```

## LU Decomposition Algorithm
The LU decomposition process follows these steps:

1. **Initialization:**
   - Create two matrices **L** and **U** of the same size as the input matrix.
   - Set diagonal elements of **L** to 1 and initialize all other elements of **L** and **U** to 0.

2. **Computing the U matrix:**
   - For each row `i`, compute the upper triangular matrix **U** by subtracting the sum of previously computed elements from the input matrix values.

3. **Computing the L matrix:**
   - For each row `i`, compute the lower triangular matrix **L** by solving for each element based on previously computed values in **L** and **U**.
   - Ensure that division by zero does not occur by checking that diagonal elements of **U** are nonzero.

4. **Output the matrices L and U in CSV format with specified accuracy.**

## Requirements
- Input and output files must be in **CSV format**.
- Input files may have inconsistencies (e.g., missing LF at the end of the line).
- If an output file already exists, it will be **overwritten**.
- The input matrix is guaranteed to have all principal minors nonzero, ensuring successful decomposition.

## Important Notes
- **The script does not modify the input matrix**.
- If the script detects an invalid value in the matrix, it will terminate with an error.
- Division by zero checks are in place to prevent errors during decomposition.

<div style="text-align: center;">
    <img src="img/popcat-meme.gif">
</div>