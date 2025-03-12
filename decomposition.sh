#!/bin/bash

export LC_NUMERIC=en_US.UTF-8


if [ "$#" -ne 4 ]; then
    echo "Использование: $0 input.csv lower.csv upper.csv accuracy"
    exit 1
fi


input_file=$1
l_file=$2
u_file=$3
accuracy=$4
temporary_accuracy=$((accuracy + 10))

mapfile -t file_lines < "$input_file"

rows=${#file_lines[@]}
cols=$(echo "${file_lines[0]}" | awk -F, '{print NF}')

matrix=()
for line in "${file_lines[@]}"; do
    line=$(echo "$line" | tr -d '[:space:]')
    if [ -n "$line" ]; then
        IFS=',' read -r -a numbers <<< "$line"
        for num in "${numbers[@]}"; do
            if [[ $num =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
                matrix+=("$num")
            else
                echo "Ошибка: некорректное значение в матрице: $num"
                exit 1
            fi
        done
    fi
done

round_number() {
    printf "%.${2}f" "$1"
}

write_matrix() {
    local file=$1
    local matrix=("${!2}")
    local rows=$3
    local cols=$4
    cat /dev/null > "$file"
    for ((i=0; i<rows; i++)); do
        line=""
        for ((j=0; j<cols; j++)); do
            local indx=$((i*cols + j))
            value=$(round_number "${matrix[$indx]}" "$accuracy")
            if [ "$j" -lt $((cols - 1)) ]; then
                line+="$value,"
            else
                line+="$value"
            fi
        done
        echo "$line" >> "$file"
    done
}

declare -A L
declare -A U

for ((i=0; i<rows; i++)); do
    for ((j=0; j<cols; j++)); do
        if [ "$i" -eq "$j" ]; then
            L["$i,$j"]=1
        else
            L["$i,$j"]=0
        fi
        U["$i,$j"]=0
    done
done

for ((i=0; i<rows; i++)); do
    for ((j=i; j<cols; j++)); do
        sum=0
        for ((k=0; k<i; k++)); do
            l_val=${L["$i,$k"]}
            u_val=${U["$k,$j"]}
            sum=$(echo "scale=$temporary_accuracy; $sum + $l_val * $u_val" | bc)
        done
        mtrx_val=${matrix[$((i*cols + j))]}
        U["$i,$j"]=$(echo "scale=$temporary_accuracy; $mtrx_val - $sum" | bc)
    done

    for ((j=i+1; j<rows; j++)); do
        sum=0
        for ((k=0; k<i; k++)); do
            l_val=${L["$j,$k"]}
            u_val=${U["$k,$i"]}
            sum=$(echo "scale=$temporary_accuracy; $sum + $l_val * $u_val" | bc)
        done
        mtrx_val=${matrix[$((j*cols + i))]}
        u_val=${U["$i,$i"]}
        if [[ $(echo "$u_val == 0" | bc) -eq 1 ]]; then
            echo "Ошибка: деление на ноль при вычислении L[$j,$i]"
            exit 1
        fi
        L["$j,$i"]=$(echo "scale=$temporary_accuracy; ($mtrx_val - $sum) / $u_val" | bc)
    done
done

l_mtrx=()
u_mtrx=()
for ((i=0; i<rows; i++)); do
    for ((j=0; j<cols; j++)); do
        l_mtrx+=("${L["$i,$j"]}")
        u_mtrx+=("${U["$i,$j"]}")
    done
done

write_matrix "$l_file" l_mtrx[@] "$rows" "$cols"
write_matrix "$u_file" u_mtrx[@] "$rows" "$cols"
