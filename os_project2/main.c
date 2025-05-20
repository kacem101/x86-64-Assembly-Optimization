#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#define MAX_STRING_LEN 100
#define MAX_ARRAY_SIZE 50

// Helper to get current time for benchmarking
long long get_nanoseconds() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000000L + ts.tv_nsec;
}

// Declare the assembly functions as external
extern long long asm_function(long long n); // Factorial
extern long long asm_fibonachi(long long n);
extern void toUpperCase(char* str);
extern void toLowerCase(char* str);
extern void reversString(char* str);
extern bool isPalindrom(char* str);
extern void stringConcat(char* dest, const char* src);
extern void strgCopy(char* dest, const char* src);
extern void asm_sort_array(long long* arr, long long size);
extern void asm_reverse_array(long long* arr, long long size);
extern void asm_reversewithstack_array(long long* arr, long long size);
extern long long asm_find_min_in_array(long long* arr, long long size);
extern long long asm_find_max_in_array(long long* arr, long long size);
extern bool linearSrch(long long* arr, long long size, long long n);
extern bool isSorted(long long* arr, long long size);
extern long long sumDiv(long long num);
extern long long isPerfect(long long num);

// C function prototypes (implementations at the bottom)
long long c_factorial(long long n);
long long c_fibonacci(long long n);
void c_toUpperCase(char* str);
void c_toLowerCase(char* str);
void c_reverseString(char* str);
bool c_isPalindrom(char* str);
void c_stringConcat(char* dest, const char* src);
void c_stringCopy(char* dest, const char* src);
void c_sort_array(long long* arr, long long size);
void c_reverse_array(long long* arr, long long size);
long long c_find_min_in_array(long long* arr, long long size);
long long c_find_max_in_array(long long* arr, long long size);
bool c_linearSearch(long long* arr, long long size, long long n);
bool c_isSorted(long long* arr, long long size);
long long c_sumDivisors(long long num);
bool c_isPerfect(long long num);

// Helper function to print an array
void print_long_long_array(const char* label, const long long* arr, long long size) {
    printf("%s: ", label);
    if (size == 0) {
        printf("(empty)\n");
        return;
    }
    for (long long i = 0; i < size; i++) {
        printf("%lld ", arr[i]);
    }
    printf("\n");
}

// Helper to clone an array
long long* clone_array(const long long* src, long long size) {
    if (!src || size <= 0) return NULL;
    long long* dest = (long long*)malloc(size * sizeof(long long));
    if (!dest) {
        perror("Failed to allocate memory for array clone");
        return NULL; // Return NULL on failure
    }
    memcpy(dest, src, size * sizeof(long long));
    return dest;
}

// Helper to read a string safely
void read_string(const char* prompt, char* buffer, int len) {
    printf("%s", prompt);
    if (fgets(buffer, len, stdin) != NULL) {
        buffer[strcspn(buffer, "\n")] = 0; // Remove trailing newline
    } else {
        buffer[0] = '\0'; // Clear buffer on fgets error
        // Clear stdin if fgets failed due to EOF or error before newline
        if (!feof(stdin) && !ferror(stdin)) {
             int c;
             while ((c = getchar()) != '\n' && c != EOF);
        }
    }
}

// Helper to read a long long safely
long long read_long_long(const char* prompt) {
    long long val;
    char input_buffer[MAX_STRING_LEN];
    while (1) {
        printf("%s", prompt);
        if (fgets(input_buffer, sizeof(input_buffer), stdin) != NULL) {
            if (sscanf(input_buffer, "%lld", &val) == 1) {
                return val;
            }
        }
        printf("Invalid input. Please enter an integer.\n");
        // Clear stdin if there was leftover input
        if (strchr(input_buffer, '\n') == NULL) { // No newline means buffer was full
            int c;
            while ((c = getchar()) != '\n' && c != EOF);
        }
    }
}

// Helper to read an array from user
long long* read_array(long long* size_out) {
    long long size;
    while (1) {
        size = read_long_long("Enter the size of the array (0 to skip, max 50): ");
        if (size >= 0 && size <= MAX_ARRAY_SIZE) break;
        printf("Invalid size. Must be between 0 and %d.\n", MAX_ARRAY_SIZE);
    }

    *size_out = size;
    if (size == 0) return NULL;

    long long* arr = (long long*)malloc(size * sizeof(long long));
    if (!arr) {
        perror("Failed to allocate memory for array");
        *size_out = 0;
        return NULL;
    }
    printf("Enter %lld integer elements for the array:\n", size);
    for (long long i = 0; i < size; i++) {
        char prompt[50];
        sprintf(prompt, "Element %lld: ", i);
        arr[i] = read_long_long(prompt);
    }
    return arr;
}


int main() {
    int choice;
    long long start_time, end_time;
    long long time_asm, time_c;

    char str_input1[MAX_STRING_LEN];
    char str_input2[MAX_STRING_LEN];
    char str_dest_asm[MAX_STRING_LEN * 2];
    char str_dest_c[MAX_STRING_LEN * 2];

    long long* user_array = NULL;
    long long user_array_size = 0;

    do {
        printf("\n--- Assembly Function Test Menu (User Input) ---\n");
        printf("1. Factorial\n");
        printf("2. Fibonacci\n");
        printf("3. To Upper Case\n");
        printf("4. To Lower Case\n");
        printf("5. Reverse String\n");
        printf("6. Is Palindrome\n");
        printf("7. String Concatenate\n");
        printf("8. String Copy\n");
        printf("9. Sort Array\n");
        printf("10. Reverse Array\n");
        printf("11. Reverse Array with Stack (ASM only)\n");
        printf("12. Find Min in Array\n");
        printf("13. Find Max in Array\n");
        printf("14. Linear Search in Array\n");
        printf("15. Is Array Sorted\n");
        printf("16. Sum of Divisors\n");
        printf("17. Is Perfect Number\n");
        printf("0. Exit\n");
        choice = read_long_long("Enter your choice: ");

        // Free previous user array if any
        if (user_array) {
            free(user_array);
            user_array = NULL;
            user_array_size = 0;
        }

        switch (choice) {
            case 1: { // Factorial
                long long n = read_long_long("Enter an integer for factorial: ");
                if (n < 0 || n > 20) { // Factorial grows very fast
                    printf("Input out of reasonable range for factorial (0-20).\n");
                    break;
                }
                printf("\nTesting Factorial for n = %lld\n", n);

                start_time = get_nanoseconds();
                long long res_asm = asm_function(n);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM Factorial: %lld (Time: %lld ns)\n", res_asm, time_asm);

                start_time = get_nanoseconds();
                long long res_c = c_factorial(n);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   Factorial: %lld (Time: %lld ns)\n", res_c, time_c);
                break;
            }
            case 2: { // Fibonacci
                long long n = read_long_long("Enter an integer for Fibonacci F(n): ");
                 if (n < 0 || n > 90) { // Avoid overflow for long long and excessive time
                    printf("Input out of reasonable range for Fibonacci (0-90).\n");
                    break;
                }
                printf("\nTesting Fibonacci for F(%lld)\n", n);

                start_time = get_nanoseconds();
                long long res_asm = asm_fibonachi(n);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM Fibonacci: %lld (Time: %lld ns)\n", res_asm, time_asm);

                start_time = get_nanoseconds();
                long long res_c = c_fibonacci(n);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   Fibonacci: %lld (Time: %lld ns)\n", res_c, time_c);
                break;
            }
            case 3: { // To Upper Case
                read_string("Enter string for toUpperCase: ", str_input1, MAX_STRING_LEN);
                printf("\nTesting To Upper Case for: \"%s\"\n", str_input1);

                strcpy(str_dest_asm, str_input1);
                start_time = get_nanoseconds();
                toUpperCase(str_dest_asm);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM toUpperCase: \"%s\" (Time: %lld ns)\n", str_dest_asm, time_asm);

                strcpy(str_dest_c, str_input1);
                start_time = get_nanoseconds();
                c_toUpperCase(str_dest_c);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   toUpperCase: \"%s\" (Time: %lld ns)\n", str_dest_c, time_c);
                break;
            }
            case 4: { // To Lower Case
                read_string("Enter string for toLowerCase: ", str_input1, MAX_STRING_LEN);
                printf("\nTesting To Lower Case for: \"%s\"\n", str_input1);

                strcpy(str_dest_asm, str_input1);
                start_time = get_nanoseconds();
                toLowerCase(str_dest_asm);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM toLowerCase: \"%s\" (Time: %lld ns)\n", str_dest_asm, time_asm);

                strcpy(str_dest_c, str_input1);
                start_time = get_nanoseconds();
                c_toLowerCase(str_dest_c);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   toLowerCase: \"%s\" (Time: %lld ns)\n", str_dest_c, time_c);
                break;
            }
            case 5: { // Reverse String
                read_string("Enter string to reverse: ", str_input1, MAX_STRING_LEN);
                printf("\nTesting Reverse String for: \"%s\"\n", str_input1);

                strcpy(str_dest_asm, str_input1);
                start_time = get_nanoseconds();
                reversString(str_dest_asm);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM reversString: \"%s\" (Time: %lld ns)\n", str_dest_asm, time_asm);

                strcpy(str_dest_c, str_input1);
                start_time = get_nanoseconds();
                c_reverseString(str_dest_c);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   reverseString: \"%s\" (Time: %lld ns)\n", str_dest_c, time_c);
                break;
            }
            case 6: { // Is Palindrome
                read_string("Enter string to check for palindrome: ", str_input1, MAX_STRING_LEN);
                printf("\nTesting Is Palindrome for: \"%s\"\n", str_input1);

                start_time = get_nanoseconds();
                bool res_asm = isPalindrom(str_input1);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM isPalindrom: %s (Time: %lld ns)\n", res_asm ? "true" : "false", time_asm);

                start_time = get_nanoseconds();
                bool res_c = c_isPalindrom(str_input1);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   isPalindrom: %s (Time: %lld ns)\n", res_c ? "true" : "false", time_c);
                break;
            }
            case 7: { // String Concatenate
                read_string("Enter destination string: ", str_dest_asm, MAX_STRING_LEN); // Use dest_asm as temp buffer
                read_string("Enter source string to concatenate: ", str_input2, MAX_STRING_LEN);
                printf("\nTesting String Concatenate\n");

                // For ASM
                char temp_dest_asm[MAX_STRING_LEN * 2];
                strcpy(temp_dest_asm, str_dest_asm); // Copy initial dest string
                start_time = get_nanoseconds();
                stringConcat(temp_dest_asm, str_input2);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM stringConcat: \"%s\" (Time: %lld ns)\n", temp_dest_asm, time_asm);

                // For C
                char temp_dest_c[MAX_STRING_LEN * 2];
                strcpy(temp_dest_c, str_dest_asm); // Copy initial dest string
                start_time = get_nanoseconds();
                c_stringConcat(temp_dest_c, str_input2);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   stringConcat: \"%s\" (Time: %lld ns)\n", temp_dest_c, time_c);
                break;
            }
            case 8: { // String Copy
                read_string("Enter source string to copy: ", str_input1, MAX_STRING_LEN);
                printf("\nTesting String Copy for src: \"%s\"\n", str_input1);

                start_time = get_nanoseconds();
                strgCopy(str_dest_asm, str_input1);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM strgCopy dest: \"%s\" (Time: %lld ns)\n", str_dest_asm, time_asm);

                start_time = get_nanoseconds();
                c_stringCopy(str_dest_c, str_input1);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   stringCopy dest: \"%s\" (Time: %lld ns)\n", str_dest_c, time_c);
                break;
            }
            case 9:   // Sort Array
            case 10:  // Reverse Array
            case 11:  // Reverse Array with Stack
            case 12:  // Find Min
            case 13:  // Find Max
            case 14:  // Linear Search
            case 15: {// Is Sorted
                if (choice >= 9 && choice <= 15) { // Common array input
                    user_array = read_array(&user_array_size);
                    if (!user_array && user_array_size > 0) { // Malloc failed
                        break;
                    }
                    if (user_array_size == 0 && (choice == 12 || choice == 13)) {
                        printf("Cannot find min/max in an empty array.\n");
                        if(user_array) free(user_array); user_array = NULL;
                        break;
                    }
                     if (user_array_size == 0 && choice == 14) {
                        printf("Cannot search in an empty array.\n");
                        if(user_array) free(user_array); user_array = NULL;
                        break;
                    }
                }

                if (choice == 9) { // Sort Array
                    printf("\nTesting Sort Array\n");
                    long long* arr_asm = clone_array(user_array, user_array_size);
                    long long* arr_c = clone_array(user_array, user_array_size);

                    if ((user_array_size > 0 && (!arr_asm || !arr_c))) {
                        printf("Memory allocation failed for sort test.\n");
                        if(arr_asm) free(arr_asm);
                        if(arr_c) free(arr_c);
                        break;
                    }
                    
                    print_long_long_array("Original", user_array, user_array_size);

                    if (arr_asm) {
                        start_time = get_nanoseconds();
                        asm_sort_array(arr_asm, user_array_size);
                        end_time = get_nanoseconds();
                        time_asm = end_time - start_time;
                        print_long_long_array("ASM Sorted", arr_asm, user_array_size);
                        printf("Time: %lld ns\n", time_asm);
                        free(arr_asm);
                    } else if (user_array_size > 0) { printf("Skipping ASM sort due to clone failure or empty array.\n");}


                    if (arr_c) {
                        start_time = get_nanoseconds();
                        c_sort_array(arr_c, user_array_size);
                        end_time = get_nanoseconds();
                        time_c = end_time - start_time;
                        print_long_long_array("C   Sorted", arr_c, user_array_size);
                        printf("Time: %lld ns\n", time_c);
                        free(arr_c);
                    } else if (user_array_size > 0) { printf("Skipping C sort due to clone failure or empty array.\n");}


                } else if (choice == 10) { // Reverse Array
                     printf("\nTesting Reverse Array\n");
                    long long* arr_asm = clone_array(user_array, user_array_size);
                    long long* arr_c = clone_array(user_array, user_array_size);

                     if ((user_array_size > 0 && (!arr_asm || !arr_c))) {
                        printf("Memory allocation failed for reverse test.\n");
                        if(arr_asm) free(arr_asm);
                        if(arr_c) free(arr_c);
                        break;
                    }

                    print_long_long_array("Original", user_array, user_array_size);
                    if(arr_asm){
                        start_time = get_nanoseconds();
                        asm_reverse_array(arr_asm, user_array_size);
                        end_time = get_nanoseconds();
                        time_asm = end_time - start_time;
                        print_long_long_array("ASM Reversed", arr_asm, user_array_size);
                        printf("Time: %lld ns\n", time_asm);
                        free(arr_asm);
                    } else if (user_array_size > 0) { printf("Skipping ASM reverse due to clone failure or empty array.\n");}


                    if(arr_c){
                        start_time = get_nanoseconds();
                        c_reverse_array(arr_c, user_array_size);
                        end_time = get_nanoseconds();
                        time_c = end_time - start_time;
                        print_long_long_array("C   Reversed", arr_c, user_array_size);
                        printf("Time: %lld ns\n", time_c);
                        free(arr_c);
                    } else if (user_array_size > 0) { printf("Skipping C reverse due to clone failure or empty array.\n");}


                } else if (choice == 11) { // Reverse Array with Stack (ASM)
                    printf("\nTesting Reverse Array with Stack (ASM only)\n");
                    long long* arr_asm = clone_array(user_array, user_array_size);
                     if (user_array_size > 0 && !arr_asm) {
                        printf("Memory allocation failed for reverse stack test.\n");
                        break;
                    }
                    print_long_long_array("Original", user_array, user_array_size);
                    if(arr_asm){
                        start_time = get_nanoseconds();
                        asm_reversewithstack_array(arr_asm, user_array_size);
                        end_time = get_nanoseconds();
                        time_asm = end_time - start_time;
                        print_long_long_array("ASM Reversed (Stack)", arr_asm, user_array_size);
                        printf("Time: %lld ns\n", time_asm);
                        free(arr_asm);
                    } else if (user_array_size > 0) { printf("Skipping ASM reverse (stack) due to clone failure or empty array.\n");}
                     else { printf("Skipping ASM reverse (stack) for empty array.\n");}


                } else if (choice == 12) { // Find Min
                    printf("\nTesting Find Min in Array\n");
                    print_long_long_array("Array", user_array, user_array_size);
                    if (user_array_size == 0) break;


                    start_time = get_nanoseconds();
                    long long min_asm = asm_find_min_in_array(user_array, user_array_size);
                    end_time = get_nanoseconds();
                    time_asm = end_time - start_time;
                    printf("ASM Min: %lld (Time: %lld ns)\n", min_asm, time_asm);

                    start_time = get_nanoseconds();
                    long long min_c = c_find_min_in_array(user_array, user_array_size);
                    end_time = get_nanoseconds();
                    time_c = end_time - start_time;
                    printf("C   Min: %lld (Time: %lld ns)\n", min_c, time_c);

                } else if (choice == 13) { // Find Max
                    printf("\nTesting Find Max in Array\n");
                    print_long_long_array("Array", user_array, user_array_size);
                     if (user_array_size == 0) break;

                    start_time = get_nanoseconds();
                    long long max_asm = asm_find_max_in_array(user_array, user_array_size);
                    end_time = get_nanoseconds();
                    time_asm = end_time - start_time;
                    printf("ASM Max: %lld (Time: %lld ns)\n", max_asm, time_asm);

                    start_time = get_nanoseconds();
                    long long max_c = c_find_max_in_array(user_array, user_array_size);
                    end_time = get_nanoseconds();
                    time_c = end_time - start_time;
                    printf("C   Max: %lld (Time: %lld ns)\n", max_c, time_c);

                } else if (choice == 14) { // Linear Search
                    printf("\nTesting Linear Search in Array\n");
                    print_long_long_array("Array", user_array, user_array_size);
                    if (user_array_size == 0) break;
                    long long val_to_find = read_long_long("Enter value to search for: ");

                    start_time = get_nanoseconds();
                    bool found_asm = linearSrch(user_array, user_array_size, val_to_find);
                    end_time = get_nanoseconds();
                    time_asm = end_time - start_time;
                    printf("ASM linearSrch: %s (Time: %lld ns)\n", found_asm ? "found" : "not found", time_asm);

                    start_time = get_nanoseconds();
                    bool found_c = c_linearSearch(user_array, user_array_size, val_to_find);
                    end_time = get_nanoseconds();
                    time_c = end_time - start_time;
                    printf("C   linearSearch: %s (Time: %lld ns)\n", found_c ? "found" : "not found", time_c);

                } else if (choice == 15) { // Is Sorted
                    printf("\nTesting Is Array Sorted\n");
                    print_long_long_array("Array", user_array, user_array_size);

                    start_time = get_nanoseconds();
                    bool sorted_asm = isSorted(user_array, user_array_size);
                    end_time = get_nanoseconds();
                    time_asm = end_time - start_time;
                    printf("ASM isSorted: %s (Time: %lld ns)\n", sorted_asm ? "true" : "false", time_asm);

                    start_time = get_nanoseconds();
                    bool sorted_c = c_isSorted(user_array, user_array_size);
                    end_time = get_nanoseconds();
                    time_c = end_time - start_time;
                    printf("C   isSorted: %s (Time: %lld ns)\n", sorted_c ? "true" : "false", time_c);
                }
                break; // Break for the block of array functions
            } // End of array function block
            case 16: { // Sum of Divisors
                long long n = read_long_long("Enter an integer for Sum of Divisors: ");
                 if (n <= 0) {
                    printf("Input must be positive.\n");
                    break;
                }
                printf("\nTesting Sum of Divisors for n = %lld\n", n);
                start_time = get_nanoseconds();
                long long sum_asm = sumDiv(n);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM SumDiv: %lld (Time: %lld ns)\n", sum_asm, time_asm);

                start_time = get_nanoseconds();
                long long sum_c = c_sumDivisors(n);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   SumDiv: %lld (Time: %lld ns)\n", sum_c, time_c);
                break;
            }
            case 17: { // Is Perfect Number
                long long n = read_long_long("Enter an integer to check if it's a Perfect Number: ");
                 if (n <= 0) {
                    printf("Input must be positive.\n");
                    break;
                }
                printf("\nTesting Is Perfect Number for n = %lld\n", n);
                start_time = get_nanoseconds();
                long long perfect_asm = isPerfect(n);
                end_time = get_nanoseconds();
                time_asm = end_time - start_time;
                printf("ASM isPerfect: %s (Time: %lld ns)\n", perfect_asm ? "true" : "false", time_asm);

                start_time = get_nanoseconds();
                bool perfect_c = c_isPerfect(n);
                end_time = get_nanoseconds();
                time_c = end_time - start_time;
                printf("C   isPerfect: %s (Time: %lld ns)\n", perfect_c ? "true" : "false", time_c);
                break;
            }
            case 0:
                printf("Exiting...\n");
                break;
            default:
                printf("Invalid choice. Please try again.\n");
        }
    } while (choice != 0);

    if (user_array) { // Final cleanup if loop exited unexpectedly
        free(user_array);
    }

    return 0;
}

// --- C Implementations for Comparison (Mostly unchanged, ensure they match ASM logic for fairness) ---

long long c_factorial(long long n) {
    if (n < 0) return -1; 
    if (n == 0) return 1;
    if (n > 20) return -2; // Approx limit for long long
    long long result = 1;
    for (long long i = 1; i <= n; i++) {
        result *= i;
    }
    return result;
}

long long c_fibonacci(long long n) {
    if (n < 0) return -1; 
    if (n == 0) return 0;
    if (n == 1) return 1;
    if (n > 92) return -2; // Approx limit for long long
    long long a = 0, b = 1, temp;
    for (long long i = 2; i <= n; i++) {
        temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

void c_toUpperCase(char* str) {
    if (!str) return;
    for (int i = 0; str[i]; i++) {
        if (str[i] >= 'a' && str[i] <= 'z') {
            str[i] = str[i] - ('a' - 'A');
        }
    }
}

void c_toLowerCase(char* str) {
    if (!str) return;
    for (int i = 0; str[i]; i++) {
        if (str[i] >= 'A' && str[i] <= 'Z') {
            str[i] = str[i] + ('a' - 'A');
        }
    }
}

void c_reverseString(char* str) {
    if (!str) return;
    int len = strlen(str);
    if (len < 2) return;
    for (int i = 0; i < len / 2; i++) {
        char temp = str[i];
        str[i] = str[len - 1 - i];
        str[len - 1 - i] = temp;
    }
}

bool c_isPalindrom(char* str) {
    if (!str) return false;
    int len = strlen(str);
    if (len < 2) return true;
    int i = 0, j = len - 1;
    while (i < j) {
        if (str[i] != str[j]) {
            return false;
        }
        i++;
        j--;
    }
    return true;
}

void c_stringConcat(char* dest, const char* src) {
    if (!dest || !src) return;
    strcat(dest, src);
}

void c_stringCopy(char* dest, const char* src) {
    if (!dest || !src) return;
    strcpy(dest, src);
}

void c_sort_array(long long* arr, long long size) { // Bubble sort
    if (!arr || size < 2) return;
    for (long long i = 0; i < size - 1; i++) {
        for (long long j = 0; j < size - 1 - i; j++) {
            if (arr[j] > arr[j + 1]) {
                long long temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

void c_reverse_array(long long* arr, long long size) {
    if (!arr || size < 2) return;
    for (long long i = 0; i < size / 2; i++) {
        long long temp = arr[i];
        arr[i] = arr[size - 1 - i];
        arr[size - 1 - i] = temp;
    }
}

long long c_find_min_in_array(long long* arr, long long size) {
    if (!arr || size == 0) return -1; // Or some error/default value like LLONG_MAX
    long long min_val = arr[0];
    for (long long i = 1; i < size; i++) {
        if (arr[i] < min_val) {
            min_val = arr[i];
        }
    }
    return min_val;
}

long long c_find_max_in_array(long long* arr, long long size) {
    if (!arr || size == 0) return -1; // Or some error/default value like LLONG_MIN
    long long max_val = arr[0];
    for (long long i = 1; i < size; i++) {
        if (arr[i] > max_val) {
            max_val = arr[i];
        }
    }
    return max_val;
}

bool c_linearSearch(long long* arr, long long size, long long n) {
    if (!arr) return false;
    for (long long i = 0; i < size; i++) {
        if (arr[i] == n) {
            return true;
        }
    }
    return false;
}

bool c_isSorted(long long* arr, long long size) {
    if (!arr || size < 2) return true;
    for (long long i = 0; i < size - 1; i++) {
        if (arr[i] > arr[i + 1]) {
            return false;
        }
    }
    return true;
}

// C sumDivisors: sum of ALL divisors, including the number itself.
// This is to match the likely behavior of your assembly sumDiv.
long long c_sumDivisors(long long num) {
    if (num <= 0) return 0;
    long long sum = 0;
    for (long long i = 1; i * i <= num; i++) {
        if (num % i == 0) {
            sum += i;
            if (i * i != num) {
                sum += num / i;
            }
        }
    }
    return sum;
}

// C isPerfect: checks if sum of ALL divisors is 2*num
bool c_isPerfect(long long num) {
    if (num <= 1) return false;
    return (c_sumDivisors(num) == (2 * num));
}
