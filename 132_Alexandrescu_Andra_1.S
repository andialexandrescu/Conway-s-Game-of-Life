.data
    m: .space 4 ;# 1<=m<=18 linii
    n: .space 4 ;# 1<=n<=18 coloane
    p: .space 4 ;# p<=m*n deoarece exista cazul in care matricea are toate celulele vii, deci nr total de perechi e nrlinii*nrcoloane
    pIndex: .space 4
    k: .space 4 ;# k<=15
    kIndex: .space 4
    i: .space 4
    j: .space 4 ;# matrix[i][j], respectiv matrixs[i][j]
    matrix: .space 1600 ;# (18+2) * (18+2) * 4
    s: .space 4 ;# folosit pentru suma vecinilor
    matrixs: .space 1600
    lineIndex: .space 4
    columnIndex: .space 4

    vIndex: .space 4 ;# va fi folosit pentru orice array de lungime messageLength
    encryptionKey: .space 1
    message: .space 11 ;# va fi un sir de maxim 10 caractere (fiecare caracter ocupa un byte) => 10 + 1 (terminator sir)
    mIndex: .space 4
    messageLength: .space 40
    maxMessageLength: .space 80 ;# poate fi maxim 80, adica 10 bytes (10 * 8 = 80)
    matrixLength: .space 4
    matrixIndex: .space 4
    key: .space 1600
    keyIndex: .space 4
    binKey: .space 10 ;# 80 impartit la 8 (aici grupez in secvente de cate 8)
    bin: .space 4
    binCh: .space 40
    binRez: .space 40
    hexRez: .space 21
    hexRez0xF: .space 21
    decRez: .space 4

    formatMessageInit: .asciz "%s"
    formatmaxMessageLength: .asciz "maxMessageLength: %ld\n"
    formatStrlen: .asciz "lungime: %ld\n"

    cript: .asciz "0x"
    chZero: .asciz "0"

    formatScanf: .asciz "%ld"
    formatPrintf: .asciz "%ld "
    formatPrintfByte: .asciz "%ld "
    formatPrintfCript: .asciz "%s"
    formatPrintfDigit: .asciz "%d"
    formatPrintfAlpha: .asciz "%c"
    newLine: .asciz "\n"
    noDecryption: .asciz "Nu am facut decriptarea\n" 
.text
strlen:
    movl $0, %ecx 
    movl 4(%esp), %ebx

    for_strlen:
        movb (%ebx), %al 
        cmpb $0, %al ;# counter care va fi incrementat cat timp sirul e diferit de caracterul null
        je strlen_exit
        
        incl %ecx
        incl %ebx
        jmp for_strlen
strlen_exit:
        movl %ecx, %eax ;# valoarea din final a counter-ului se va afla in %eax
        ret
.global main
main:
    ;# citire m linii
    pushl $m
    pushl $formatScanf
    call scanf
    add $8, %esp

    ;# citire n coloane
    pushl $n
    pushl $formatScanf
    call scanf
    add $8, %esp

    ;# citire p - nr celule vii
    pushl $p
    pushl $formatScanf
    call scanf
    add $8, %esp

    movl $0, pIndex
    addl $2, m
    addl $2, n
for_perechi: ;# for(pIndex=0; pIndex<p; pIndex++)
    movl pIndex, %ecx
    cmp %ecx, p
    je citire_k_criptare_message

    ;# citire pozitiile din matrice la care se afla celulele vii
    pushl $i
    pushl $formatScanf
    call scanf
    add $8, %esp

    pushl $j
    pushl $formatScanf
    call scanf
    add $8, %esp

    ;# for(i=0; i<m_init+2; i++){ for(j=0; j<n_init+2; j++) ... }
    ;# matrix[i+1][j+1] = 1 (celula vie); eax = (i+1) * (n_init+2) + (j+1); GRAF ORIENTAT
    movl i, %eax
    addl $1, %eax
    movl $0, %edx ;# pt a nu afecta inmultirea
    mull n
    addl j, %eax
    addl $1, %eax
    lea matrix, %edi
    movl $1, (%edi, %eax, 4)

    incl pIndex
    jmp for_perechi
citire_k_criptare_message:
    ;# citire k - nr evolutii
    pushl $k
    pushl $formatScanf
    call scanf
    addl $8, %esp

    ;# citire criptare/decriptare
    pushl $encryptionKey
    pushl $formatScanf
    call scanf
    addl $8, %esp

    ;# citire message
    pushl $message
    pushl $formatMessageInit
    call scanf
    addl $8, %esp

strlen_mesaj:;# apelul procedurii strlen pentru a determina lungimea lui message
    lea message, %edi ;# message se afla la inceputul adresei %edi/ e relativ la %edi
    push %edi
    call strlen
    add $4, %esp
    
    movl %eax, messageLength

pre_afis_k_evolutie:
    ;# doar in eticheta for_perechi, care parcurge matricea extinsa si atribuie val de 1 perechilor de noduri (i, j), este nevoie de m_init+2 si n_init+2, deci se revine la valorile initiale introduse [ocazional vor trebui sa se realizeze operatiile addl $2, n si subl $2, n, din moment ce matricele matrix si matrixs au elemente care se apeleaza dupa formula (lineIndex+1)*(n_init+2)+(columnIndex)]
    subl $2, m 
    subl $2, n
    
    movl $0, kIndex
afis_k_evolutie: ;# for(kIndex=0; kIndex<k; kIndex++)
    movl kIndex, %ecx
    cmp %ecx, k
    je et_decizie
    
    ;# prelucrari
    ;# MOD DE APELARE (chain de etichete): compunere matrice s -> analiza evolutie -> etichete intermediare -> afisare analiza evolutie
    jmp compunere_matrice_s
    
cont_afis_k_evolutie:
    incl kIndex
    jmp afis_k_evolutie

compunere_matrice_s: 
    movl $0, lineIndex
    for1_linii: ;# for(lineIndex=0; lineIndex<m_init; lineIndex++)
        movl lineIndex, %ecx
        cmp %ecx, m
        je analiza_evolutie

        movl $0, columnIndex
        for1_coloane: ;# for(columnIndex=0; columnIndex<n_init; columnIndex++)
            movl columnIndex, %ecx
            cmp %ecx, n
            je cont_for1_linii
            
	    movl s, %ebx
	    addl $2, n

            ;# a[i-1][j-1] => (lineIndex) * (n_init+2) + (columnIndex)
            movl lineIndex, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i-1][j] => (lineIndex) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $1, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i-1][j+1] => (lineIndex) * (n_init+2) + (columnIndex+2)
            movl lineIndex, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $2, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i][j-1] => (lineIndex+1) * (n_init+2) + (columnIndex)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i][j+1] => (lineIndex+1) * (n_init+2) + (columnIndex+2)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $2, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i+1][j-1] => (lineIndex+2) * (n_init+2) + (columnIndex)
            movl lineIndex, %eax
            addl $2, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i+1][j] => (lineIndex+2) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $2, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $1, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# a[i+1][j+1] => (lineIndex+2) * (n_init+2) + (columnIndex+2)
            movl lineIndex, %eax
            addl $2, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $2, %eax

            lea matrix, %edi
            addl (%edi, %eax, 4), %ebx
            
            ;# el curent din matrixs => (lineIndex+1) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            mull n
            addl columnIndex, %eax
            addl $1, %eax
            
            lea matrixs, %edi
            movl %ebx, (%edi, %eax, 4)
            
            incl columnIndex
            subl $2, n
            jmp for1_coloane

    cont_for1_linii:
        incl lineIndex
        jmp for1_linii

analiza_evolutie:
    movl $0, lineIndex
    for2_linii: ;# for(lineIndex=0; lineIndex<m_init; lineIndex++)
        movl lineIndex, %ecx
        cmp %ecx, m
        je cont_afis_k_evolutie

        movl $0, columnIndex
        for2_coloane: ;# for(columnIndex=0; columnIndex<n_init; columnIndex++)
            movl columnIndex, %ecx
            cmp %ecx, n
            je cont_for2_linii
            
            ;# eax = (lineIndex+1) * (n_init+2) + (columnIndex+1)
            movl lineIndex, %eax
            addl $1, %eax
            movl $0, %edx
            addl $2, n
            mull n
            subl $2, n
            addl columnIndex, %eax
            addl $1, %eax
   
            lea matrix, %edi
            movl (%edi, %eax, 4), %ebx
            
            ;# if(matrix[lineIndex+1][columnIndex+1]==1): jmp celula_vie else: jmp celula_moarta
            cmp $1, %ebx
            je celula_vie
            cmp $0, %ebx
            je celula_moarta
            
cont_analiza_evolutie:
            incl columnIndex
            jmp for2_coloane

    cont_for2_linii:
        incl lineIndex
        jmp for2_linii
        
celula_vie:
    ;# in ebx e elementul curent, adica celula vie, iar in eax e pozitia curenta a celulei
    lea matrixs, %esi
    movl (%esi, %eax, 4), %ebx ;# compar elementul corespunzator din matrixs (pt ca suma e corespondenta elementului curent verificat)
    
    cmp $2, %ebx
    jb elem_modif_in_0
    
    cmp $3, %ebx
    jg elem_modif_in_0
    
    cont_celula_vie:
        jmp cont_analiza_evolutie
    
celula_moarta:
    ;# in ebx e elementul curent, adica celula moarta, iar in eax e pozitia curenta a celulei
    lea matrixs, %esi
    movl (%esi, %eax, 4), %ebx
    
    cmp $3, %ebx
    je elem_modif_in_1
    
    cont_celula_moarta:
        jmp cont_analiza_evolutie
        
elem_modif_in_0:
    lea matrix, %edi
    movl $0, (%edi, %eax, 4)
    
    jmp cont_celula_vie
    
elem_modif_in_1:
    lea matrix, %edi
    movl $1, (%edi, %eax, 4)
    
    jmp cont_celula_moarta


et_decizie:
    cmpl $0, encryptionKey
    je pre_compunere_key

    cmpl $1, encryptionKey
    je fara_decriptare

pre_compunere_key:
    ;# calcul lungime matrix: (m_init+2) * (n_init+2)
    addl $2, m
    addl $2, n
    movl m, %eax
    movl $0, %edx
    mull n
    movl %eax, matrixLength

    movl $0, keyIndex
compunere_key:

    parcurgere_k_evolutie:
        movl $0, lineIndex
        for3_linii: ;# for(lineIndex=0; lineIndex<m_init+2; lineIndex++)
            movl lineIndex, %ecx
            cmp %ecx, m
            je et_comparare_lungimi

            movl $0, columnIndex
            for3_coloane: ;# for(columnIndex=0; columnIndex<n_init+2; columnIndex++)
                movl columnIndex, %ecx
                cmp %ecx, n
                je cont_for3_linii

                ;# eax = (lineIndex) * (n_init+2) + (columnIndex)
                movl lineIndex, %eax
                movl $0, %edx
                mull n
                addl columnIndex, %eax

                lea matrix, %edi
                movl (%edi, %eax, 4), %ebx

                ;# %esi + keyIndex * 4
                movl keyIndex, %eax
                lea key, %esi
                movl %ebx, (%esi, %eax, 4)
                ;# nu e nevoie de restaurare a lui eax (pushl + popl)

                ;#pusha
                ;#pushl %ebx
                ;#pushl $formatPrintf
                ;#call printf
                ;#add $8, %esp
                ;#popa

                ;#pushl $0
                ;#call fflush
                ;#popl %ebx

                incl keyIndex
                incl columnIndex
                jmp for3_coloane
        cont_for3_linii:
            incl lineIndex
            jmp for3_linii
et_comparare_lungimi:
    ;# calcul lungime maxMessageLength
    movl $8, %eax
    movl $0, %edx
    mull messageLength
    movl %eax, maxMessageLength

    movl matrixLength, %eax
    cmp %eax, maxMessageLength
    jle compunere_binKey

adaugare_compunere_key:
    movl $0, matrixIndex

    movl matrixLength, %ebx
    movl %ebx, keyIndex
    for_keyIndex: ;# for(int keyIndex=matrixLength; keyIndex<maxMessageLength; keyIndex++)
        movl keyIndex, %ecx
        cmp %ecx, maxMessageLength
        je compunere_binKey

        movl matrixLength, %eax
        cmp %eax, matrixIndex
        jl fara_reinit_matrixIndex

        ;# reinitializare matrixIndex
        movl $0, matrixIndex

    fara_reinit_matrixIndex:
        lea key, %esi

        movl matrixIndex, %eax
        movl (%esi, %eax, 4), %edx ;# edx se comporta ca o variabila auxiliara; key[matrixIndex]
        
        movl keyIndex, %eax
        movl %edx, (%esi, %eax, 4) ;# key[keyIndex] = key[matrixIndex]

        incl matrixIndex
        incl keyIndex
        jmp for_keyIndex

compunere_binKey:
    movl $0, i

    movl $0, keyIndex
for_keyIndex2:;# for(int keyIndex=0; keyIndex<messageLength; keyIndex++)
    movl keyIndex, %ecx
    cmp %ecx, messageLength
    je init_for_caracter_mesaj

    movl $0, bin 

    movl $0, j
    for_bit_conversie:;# for(int j=0; j<8; j++)
        movl j, %ecx
        cmpl $8, %ecx
        je stocheaza_byte
        
        movl i, %ecx
        cmpl %ecx, maxMessageLength
        jle stocheaza_byte

        ;# bin va reprezenta secventa formata din cate 8 biti stocati succesiv in key
        shlb $1, bin
        lea key, %esi
        movl (%esi, %ecx, 4), %eax ;# bit-ul de rang i
        orb %al, bin

        incl i

        incl j
        jmp for_bit_conversie

    stocheaza_byte:
        lea binKey, %edi
        movl keyIndex, %ecx
        movb bin, %dl
        movb %dl, (%edi, %ecx)
        ;# binKey[keyIndex] = bin
        
    incl keyIndex
    jmp for_keyIndex2

init_for_caracter_mesaj:
    lea message, %edi
    movl $0, mIndex
for_caracter_mesaj: ;# for(mIndex=0; mIndex<messageLength; mIndex++)
    movl mIndex, %ecx
    cmp %ecx, messageLength
    je init_et_xor
    
    ;# fiecare caracter e indicat prin pozitia (%edi + %ecx)
    ;#movzbl (%edi, %ecx), %ebx ;# valoarea ASCII a caracterului curent se va afla in ebx, iar in ecx e counter-ul MIndex; move zero-extended byte to zero va completa cu zero-uri pana la 32 de biti
    xor %eax, %eax
    movb (%edi, %ecx), %al
    
        lea binCh, %esi
    compunere_vector_binCh:
        ;#movl %ebx, (%esi, %ecx, 4)
        movb %al, (%esi, %ecx, 4)
        
    ;#afis_secv_caractere:   
        ;#pusha
        ;#pushl %eax
        ;#pushl $formatPrintf
        ;#call printf
        ;#addl $8, %esp
        ;#popa
        
        ;#pushl $0
        ;#call fflush
        ;#addl $4, %esp
        
cont_for_caracter_mesaj:
    incl mIndex
    jmp for_caracter_mesaj

init_et_xor:

    movl $0, vIndex
et_xor:;# for(int vIndex=0; vIndex<messageLength; vIndex++)
    movl vIndex, %ecx
    cmp %ecx, messageLength
    je init_conversie

    ;# rezultatul xor-arii se afla in edx
    lea binCh, %edi
    movl (%edi, %ecx, 4), %edx
    andl $0xFF, %edx
    lea binKey, %esi
    xorb (%esi, %ecx), %dl

    ;# binRez[vIndex] = %edx; (%esi, %ecx, 4) = %edx
    lea binRez, %esi
    movl %edx, (%esi, %ecx, 4)

    ;#pusha
    ;#push %edx
    ;#push $formatPrintf
    ;#call printf
    ;#addl $8, %esp
    ;#popa

    ;#pushl $0
    ;#call fflush
    ;#addl $4, %esp

    incl vIndex
    jmp et_xor

init_conversie:
    pusha
    pushl $cript
    pushl $formatPrintfCript
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp

init_for_vIndex3:    
    movl $0, i
    movl $0, j;# binRez0xF[]
    movl $0, vIndex
for_vIndex3:
    movl vIndex, %ecx
    cmpl %ecx, messageLength
    je et_exit

    lea binRez, %esi
    movl (%esi, %ecx, 4), %eax
    movl %eax, decRez

testare_decRez:
    cmpl $0, decRez
    je cont_hexaRez

    lea hexRez, %edi

    movl decRez, %eax
    andl $0xF, %eax
    movl i, %edx
    movl %eax, (%edi, %edx)
    
    ;# afisare hexRez
    ;#pusha
    ;#pushl %eax
    ;#pushl $formatPrintf
    ;#call printf
    ;#addl $8, %esp
    ;#popa
    
    ;#pushl $0
    ;#call fflush
    ;#addl $4, %esp
    
    shrl $4, decRez
    cmpl $0, decRez
    jne compunere_hexRez0xF
    
    cmpl $0, decRez
    je et_index_i
et_intoarcere_testare_decRez:
    jmp testare_decRez
et_index_i:
    incl i
    jmp et_intoarcere_testare_decRez
compunere_hexRez0xF:    
    lea hexRez0xF, %esi
    movl j, %ebx
    movl %eax, (%esi, %ebx)
    incl j
    jmp et_intoarcere_testare_decRez

cont_hexaRez:
    lea binRez, %esi
    movl vIndex, %ecx
    cmpl $16, (%esi, %ecx, 4)
    jl exceptie_mai_mic_16
    
    movl i, %ecx
    subl $1, %ecx
    lea hexRez, %edi
    movl (%edi, %ecx), %eax
    cmpl $10, %eax
    jl afis_format_cifra1
    jmp afis_format_litera1
    et_intoarcere:
        lea hexRez0xF, %edi
        movl j, %ecx
        subl $1, %ecx
        movl (%edi, %ecx), %eax
        cmpl $10, %eax
        jl afis_format_cifra2
        jmp afis_format_litera2

cont_for_vIndex3:
    incl vIndex
    jmp for_vIndex3

afis_format_cifra1:
    pusha
    pushl %eax
    pushl $formatPrintfDigit
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp

    jmp et_intoarcere

afis_format_litera1:
    pusha
    addl $55, %eax
    pushl %eax
    pushl $formatPrintfAlpha
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp

    jmp et_intoarcere
afis_format_cifra2:
    pusha
    pushl %eax
    pushl $formatPrintfDigit
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp

    jmp cont_for_vIndex3

afis_format_litera2:
    pusha
    addl $55, %eax
    pushl %eax
    pushl $formatPrintfAlpha
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp

    jmp cont_for_vIndex3

exceptie_mai_mic_16:
    movl $4, %eax
    movl $1, %ebx
    movl $chZero, %ecx
    movl $2, %edx
    int $0x80
    
    lea binRez, %esi
    movl vIndex, %ecx
    movl (%esi, %ecx, 4), %ebx
    
    cmpl $10, %ebx
    jge afis_intre_10_16
    
    pusha
    pushl %ebx
    pushl $formatPrintfDigit
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp
    
    jmp skip_afis_10_16
    afis_intre_10_16:
    pusha
    addl $55, %ebx
    pushl %ebx
    pushl $formatPrintfAlpha
    call printf
    addl $8, %esp
    popa

    pushl $0
    call fflush
    addl $4, %esp
skip_afis_10_16:
    jmp cont_for_vIndex3
    
fara_decriptare:
    movl $4, %eax
    movl $1, %ebx
    movl $noDecryption, %ecx
    movl $25, %edx
    int $0x80
et_exit:
    movl $1, %eax
    xor %ebx, %ebx
    int $0x80
