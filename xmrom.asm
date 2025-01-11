osfind = &FFCE
osbget = &FFD7
osargs = &FFDA
osrdch = &FFE0
osasci = &FFE3
osnewl = &FFE7
oswrch = &FFEE
osbyte = &FFF4
comline = &F2

tmp = &80
csum = &81
memptrL = &82
memptrH = &83
SOH = &1
EOT = &4
ACK = &6
NAK = &15

ORG &8000
.start
    EQUB 0, 0, 0 \ language entry point
    JMP service  \ service entry point
    EQUB &82     \ ROM type
    EQUB offset MOD 256
    EQUB 1       \ version
.title
    EQUS "XModem ROM"
    EQUB 0
    EQUS "0.1"
.offset
    EQUB 0
    EQUS "(C) 2025 Chris Sawer"
    EQUB 0

.service
    PHA
    CMP #9 : BEQ help
    CMP #4 : BEQ u8beeb
    PLA
    RTS

.help
    TYA : PHA
    TXA : PHA
    JSR doHelp
    PLA : TAX
    PLA : TAY
    PLA
    RTS

.doHelp
    JSR osnewl
    LDX #0
    LDA title,X
.helpLoop
    JSR osasci
    INX
    LDA title,X
    BNE helpLoop
    JSR osnewl
    RTS

.u8beeb
    TYA : PHA
    TXA : PHA
    LDX #&FF
    DEY
.u8beebCommandLoop
    INX
    INY
    LDA (comline),Y
    AND #&DF \ uppercase
    CMP command,X
    BEQ u8beebCommandLoop
    LDA command,X
    BPL done
    CMP #&FF
    BNE done
    JSR init
    PLA
    PLA
    PLA
    LDA #&00
    RTS
.done
    PLA : TAX
    PLA : TAY
    PLA
    RTS

.command
    EQUS "XMROM"
    EQUB &FF

.init
    LDA #&1F:STA memptrH:LDA #&80:STA memptrL \ &2000-&80
    LDA #7:LDX #7:JSR osbyte \ 9600 receive
    LDA #8:LDX #7:JSR osbyte \ 9600 transmit
    LDA #2:LDX #2:JSR osbyte \ enable RS423 input
    LDA #&15:LDX #1:JSR osbyte \ flush RS423 input
    LDA #NAK:JSR sendByte
.startBlock
    JSR readByte:CPY #EOT:BEQ gotEot
    CPY #SOH:BNE fail
    JSR readByte:STY tmp
    JSR readByte:TYA:CLC:ADC tmp
    CMP #&FF:BNE fail
    CLC:LDA memptrL:ADC #&80:STA memptrL
    LDA memptrH:ADC #0:STA memptrH
    LDY #0:STY csum
.loop
    TYA:PHA
    JSR readByte
    TYA:TAX:CLC:ADC csum:STA csum
    PLA:TAY
    TXA:STA (memptrL),Y
    INY:CPY #128
    BNE loop
    JSR readByte:CPY csum:BNE fail
    LDA #ACK:JSR sendByte
    LDA #'B':JSR oswrch
    JMP startBlock
    RTS
.sendByte
    PHA
    LDA #3:LDX #3:JSR osbyte \ enable RS423 output
    PLA:JSR oswrch
    LDA #3:LDX #0:JSR osbyte \ enable screen output
    RTS
.readByte \ blocks, returns byte in Y
    LDA #&91:LDX #1:JSR osbyte
    BCS readByte
    RTS
.fail
    LDA #'X':JSR oswrch
    RTS
.gotEot
    LDA #ACK:JSR sendByte
    RTS
.end

SAVE "xmrom", start, end
