// Lab 9 testbench
// Do not modify this file.  We will use our own copy of this 
// file to autograde your Verilog.
// 
// You are still welcome to look through to learn how to write 
// Verilog testbenches in C++ using Verilator.
//======================================================================

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>
#include "verilated_fst_c.h"

// Verilator using new C++?  Need to include these now
#include <iostream>

const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
VerilatedFstC* tfp = new VerilatedFstC;

// Current simulation time (64-bit unsigned)
vluint64_t main_time = 0;
// Called by $time in Verilog
double sc_time_stamp()
{
  return main_time; // Note does conversion to real, to match SystemC
}

int concat(int w, int a, int b)
{
  return (a << w) | b;
}

int pin(int a, int b) {
  return (a >> b) & 1;
}

int pinsel(int x, int a, int b) {
    assert(a < b);
    int y = 0;
    for (int i = a; i <= b; i++) {
        y |= pin(x, i);
    }
    return y;
}

int intssenc (int x) {
    switch (x) {
        case -2: return 64; // dash
        case -1: return 0;  // blank
        case 0 : return 63;
        case 1 : return 6;
        case 2 : return 91;
        case 3 : return 79;
        case 4 : return 102;
        case 5 : return 109;
        case 6 : return 125;
        case 7 : return 7;
        case 8 : return 127;
        case 9 : return 103;
        case 10: return 119;
        case 11: return 124;
        case 12: return 57;
        case 13: return 94;
        case 14: return 121;
        case 15: return 113;
    }
    // uhhh this should not happen
    assert(false);
    return -255;
}

int intssdec (int x) {
    switch (x) {
        case 64: return -2; // dash
        case 0: return -1;  // blank
        case 63 : return 0;
        case 6 : return 1;
        case 91 : return 2;
        case 79 : return 3;
        case 102 : return 4;
        case 109 : return 5;
        case 125 : return 6;
        case 7 : return 7;
        case 127 : return 8;
        case 103 : return 9;
        case 119: return 10;
        case 124: return 11;
        case 57: return 12;
        case 94: return 13;
        case 121: return 14;
        case 113: return 15;
        default: return -2;
    }
    // uhhh this should not happen
    assert(false);
    return -255;
}

std::string bin(uint64_t b)
{
  std::string ans;
  while (b != 0)
  {
    ans += b % 2 == 0 ? "0" : "1";
    b /= 2;
  }
  std::reverse(ans.begin(), ans.end());
  return ans;
}

std::string padbin(uint64_t b, int n)
{
  std::string ans;
  while (b != 0)
  {
    ans += b % 2 == 0 ? "0" : "1";
    b /= 2;
    n--;
  }
  while (n-- != 0) {
    ans += "0";
  }
  std::reverse(ans.begin(), ans.end());
  return ans;
}

// Include model header, generated from Verilating the Verilog module.
#if defined(KEYSYNC)
    #include "Vkeysync.h"
    void eval(Vkeysync *keysync) {
      contextp->timeInc(1);
      keysync->eval();
      tfp->dump(contextp->time());
    }
    void cycle_clock(Vkeysync *keysync) {
      keysync->clk = 1; eval(keysync);
      keysync->clk = 0; eval(keysync);
    }
#elif defined(CLOCK_PSC)
    #include "Vclock_psc.h"
    void eval(Vclock_psc *clock_psc) {
      contextp->timeInc(1);
      clock_psc->eval();
      tfp->dump(contextp->time());
    }
    void cycle_clock(Vclock_psc *clock_psc) {
      clock_psc->clk = 1; eval(clock_psc);
      clock_psc->clk = 0; eval(clock_psc);
    }
#elif defined(SEQUENCE_SR)
    #include "Vsequence_sr.h"
    void eval(Vsequence_sr *sequence_sr) {
      contextp->timeInc(1);
      sequence_sr->eval();
      tfp->dump(contextp->time());
    }
    void cycle_clock(Vsequence_sr *sequence_sr) {
      sequence_sr->clk = 1; eval(sequence_sr);
      sequence_sr->clk = 0; eval(sequence_sr);
    }
#elif defined(FSM)
    #include "Vfsm.h"
    // states are LS0, LS1... LS7, INIT, OPEN, ALARM with values corresponding to index
    typedef enum {LS0, LS1, LS2, LS3, LS4, LS5, LS6, LS7, INIT, OPEN, ALARM} state_t;
    void eval(Vfsm *fsm) {
      contextp->timeInc(1);
      fsm->eval();
      tfp->dump(contextp->time());
    }
    void cycle_clock(Vfsm *fsm) {
      fsm->clk = 1; eval(fsm);
      fsm->clk = 0; eval(fsm);
    }
    std::string get_state_names(int state) {
      switch(state) {
        case LS0: return "LS0";
        case LS1: return "LS1";
        case LS2: return "LS2";
        case LS3: return "LS3";
        case LS4: return "LS4";
        case LS5: return "LS5";
        case LS6: return "LS6";
        case LS7: return "LS7";
        case INIT: return "INIT";
        case OPEN: return "OPEN";
        case ALARM: return "ALARM";
      }
      // otherwise return state number as string
      return std::to_string(state);
    }
#elif defined(DISPLAY)
    // states are LS0, LS1... LS7, INIT, OPEN, ALARM with values corresponding to index
    typedef enum {LS0, LS1, LS2, LS3, LS4, LS5, LS6, LS7, INIT, OPEN, ALARM} state_t;
    #include "Vdisplay.h"
    void eval(Vdisplay *display) {
      contextp->timeInc(1);
      display->eval();
      tfp->dump(contextp->time());
    }
    static uint64_t m_secure = 0b011011010111100100111001001111100101000001111001;
    static uint64_t m_open = 0b00111111011100110111100101010100;
    static uint64_t m_alarm = 0b0011100101110111001110000011100000000000011001110000011000000110;
    static uint64_t exp_ss, exp_green, exp_blue, exp_red;
    void check_outputs(Vdisplay* display, int *pt, int *tt) {
      (*tt)++;
      if (display->ss == exp_ss)
        (*pt)++;
      else
        std::cout << "ss = 0x" << std::hex << display->ss << ", expected 0x" << std::hex << exp_ss << "\n";
      (*tt)++;
      if (display->green == exp_green)
        (*pt)++;
      else
        std::cout << "green = " << std::to_string(display->green) << ", expected " << exp_green << "\n";
      (*tt)++;
      if (display->blue == exp_blue)
        (*pt)++;
      else
        std::cout << "blue = " << std::to_string(display->blue) << ", expected " << exp_blue << "\n";
      (*tt)++;
      if (display->red == exp_red)
        (*pt)++;
      else
        std::cout << "red = " << std::to_string(display->red) << ", expected " << exp_red << "\n";
    }
    std::string get_state_names(int state) {
      switch(state) {
        case LS0: return "LS0";
        case LS1: return "LS1";
        case LS2: return "LS2";
        case LS3: return "LS3";
        case LS4: return "LS4";
        case LS5: return "LS5";
        case LS6: return "LS6";
        case LS7: return "LS7";
        case INIT: return "INIT";
        case OPEN: return "OPEN";
        case ALARM: return "ALARM";
      }
      // otherwise return state number as string
      return std::to_string(state);
    }
#elif defined(TOPMOD)
    #include "Vtop.h"
    static uint64_t exp_ss = 0;
    static uint64_t exp_right = 0;
    static uint64_t exp_g = 0;
    static uint64_t exp_b = 0;
    static uint64_t exp_r = 0;
    void eval(Vtop *top) {
      contextp->timeInc(1);
      top->eval();
      tfp->dump(contextp->time());
    }
    void cycle_clock(Vtop *top) {
      top->hz100 = 1; eval(top);
      top->hz100 = 0; eval(top);
    }
    void cycle_reset(Vtop *top) {
      top->reset = 1; eval(top);
      top->reset = 0; eval(top);
    }
    int ss (Vtop* top, int i) {
      switch(i) {
        case 0: return top->ss0 & 0xFF;
        case 1: return top->ss1 & 0xFF;
        case 2: return top->ss2 & 0xFF;
        case 3: return top->ss3 & 0xFF;
        case 4: return top->ss4 & 0xFF;
        case 5: return top->ss5 & 0xFF;
        case 6: return top->ss6 & 0xFF;
        case 7: return top->ss7 & 0xFF;
      }
      assert(false);
      return 0;
    }
    void check_outputs(Vtop* top, int *pt, int *tt) {
      uint64_t top_ss = 0;
      for (int i = 7; i >= 0; i--) {
        top_ss = (top_ss << 8) | ss(top, i);
      }
      (*tt)++;
      if (top_ss == exp_ss)
        (*pt)++;
      else
        std::cout << "ss = 0x" << std::hex << top_ss << ", expected 0x" << std::hex << exp_ss << "\n";
      (*tt)++;
      if (top->right == exp_right)
        (*pt)++;
      else
        std::cout << "right = 0b" << padbin(top->right, 8) << ", expected 0b" << padbin(exp_right, 8) << "\n";
      (*tt)++;
      if (top->green == exp_g)
        (*pt)++;
      else
        std::cout << "green = " << std::to_string(top->green) << ", expected " << exp_g << "\n";
      (*tt)++;
      if (top->blue == exp_b)
        (*pt)++;
      else
        std::cout << "blue = " << std::to_string(top->blue) << ", expected " << exp_b << "\n";
      (*tt)++;
      if (top->red == exp_r)
        (*pt)++;
      else
        std::cout << "red = " << std::to_string(top->red) << ", expected " << exp_r << "\n";
    }
    void assert_key(Vtop* top, uint32_t pb) {
      // clear synckey strobe
      top->pb = 0;
      cycle_clock(top);
      cycle_clock(top);
      // set key and strobe goes high 2 rising-edges later
      top->pb = pb;
      cycle_clock(top);
      cycle_clock(top);
    }
#else
    #error "No module specified"
#endif

static int passed_test_count = 0; // every time we perform a test, and the test passes, increment this by one.
static int total_test_count = 0;  // every time we perform a test, increment this by one.

void update_tests(int passed, int total, std::string test) {
  // add tests to global test variables
  passed_test_count += passed;
  total_test_count += total;
  // perform sanity check on global test variables
  assert(passed_test_count <= total_test_count);
  // let TA know if this set of tests failed
  std::cout << "Part " << test << ": " << std::to_string(passed) << " out of " << std::to_string(total) << " tests passed.\n";
}

int main(int argc, char **argv)
{
  // This is a more complicated example, please also see the simpler examples/make_hello_c.

  // Prevent unused variable warnings
  if (0 && argc && argv) {}

  int passed_subtests = 0; // if we have multiple subtests, we need to know how many passed for each
  int total_subtests = 0;
  
  // Set debug level, 0 is off, 9 is highest presently used
  // May be overridden by commandArgs argument parsing
  contextp->debug(0);

  // Randomization reset policy
  // May be overridden by commandArgs argument parsing
  contextp->randReset(2);

  // Verilator must compute traced signals
  contextp->traceEverOn(true);

  // Pass arguments so Verilated code can see them, e.g. $value$plusargs
  // This needs to be called before you create any model
  contextp->commandArgs(argc, argv);

  #if defined(CLOCK_PSC)
    std::cout << "Testing clock_psc...\n";
    // Construct the Verilated model, from each module after Verilating each module file
    const std::unique_ptr<Vclock_psc> clkpsc {new Vclock_psc {contextp.get(), "CLOCK_PSC"} };
    clkpsc->trace(tfp, 99);
    tfp->open("clock_psc.fst");
    
    // in: clk, rst, lim, out: hzX
    // test lim == 0 - hzX must be clk
    clkpsc->lim = 0;
    clkpsc->clk = 0;
    std::cout << "Testing power-on reset.\n";
    clkpsc->rst = 0;
    eval(clkpsc.get());
    clkpsc->rst = 1;
    eval(clkpsc.get());
    clkpsc->rst = 0;
    eval(clkpsc.get());
    std::cout << "Testing lim == 0 - clk and hzX should be the same.\n";
    for (int i = 0; i < 16; i++) {
      cycle_clock(clkpsc.get());
      total_subtests++;
      if (clkpsc->hzX == clkpsc->clk)
        passed_subtests++;
      else
        std::cout << "Test " << std::dec << total_subtests << ": hzX = " << std::to_string(clkpsc->hzX) << ", expected " << std::to_string(clkpsc->clk) << "\n";
    }
    
    // test lim == 1 - hzX must be clk
    for (clkpsc->lim = 1; clkpsc->lim < 200; clkpsc->lim++) {
      // std::cout << "Testing lim == " << std::to_string(clkpsc->lim) << ".\n";
      // reset everything so we can count properly again.
      clkpsc->rst = 1;
      eval(clkpsc.get());
      clkpsc->rst = 0;
      eval(clkpsc.get());
      // clkpsc should function by counting from 0 to clkpsc->lim, then toggling clkpsc->hzX
      // frequency = 100 Hz / (clkpsc->lim)
      int ctr = 0;
      int expected_clk = 0;
      for (int i = 0; i < 200; i++) {
        cycle_clock(clkpsc.get());
        total_subtests++;
        if (ctr == clkpsc->lim) {
          ctr = 0;
          expected_clk = ~expected_clk & 0x1;
        } else {
          ctr++;
        }
        if (clkpsc->hzX == expected_clk)
          passed_subtests++;
        else
          std::cout << "Test " << std::dec << total_subtests << ": hzX = " << std::to_string(clkpsc->hzX) << ", expected " << std::to_string(expected_clk) << ". (ctr/clkpsc->lim) " << std::to_string(ctr) << "/" << std::to_string(clkpsc->lim) << "\n";
      }
      
    }
  #elif defined(KEYSYNC)
    std::cout << "Testing keysync...\n";
    // Construct the Verilated model, from each module after Verilating each module file
    const std::unique_ptr<Vkeysync> keysync {new Vkeysync {contextp.get(), "KEYSYNC"} };
    keysync->trace(tfp, 99);
    tfp->open("keysync.fst");

    keysync->clk = 0;
    keysync->rst = 0;
    keysync->keyin = 0;
    eval(keysync.get());

    keysync->rst = 1;
    eval(keysync.get());
    if (keysync->keyout == 0 && keysync->keyclk == 0)
      passed_subtests++;
    total_subtests++;

    keysync->rst = 0;
    eval(keysync.get());

    for(int i = 1; i < 1<<20; i++) {
      int bits = 0;
      keysync->keyin = i;
      eval(keysync.get());
      bits |= pin(keysync->keyin,19) | pin(keysync->keyin,17) | pin(keysync->keyin,15) | pin(keysync->keyin,13) | pin(keysync->keyin,11) | pin(keysync->keyin,9) | pin(keysync->keyin,7) | pin(keysync->keyin,5) | pin(keysync->keyin,3) | pin(keysync->keyin,1);
      bits |= (pinsel(keysync->keyin,18,19) | pinsel(keysync->keyin,14,15) | pinsel(keysync->keyin,10,11) | pinsel(keysync->keyin,6,7) | pinsel(keysync->keyin,2,3)) << 1;
      bits |= (pinsel(keysync->keyin,12,15) | pinsel(keysync->keyin,4,7)) << 2;
      bits |= (pinsel(keysync->keyin,8,15)) << 3;
      bits |= (pinsel(keysync->keyin,16,19)) << 4;
      // keysync->keyout MUST be combinational.
      if (keysync->keyout == bits)
        passed_subtests++;
      //else	// Yeahhhh... for the love of God please do not print out 1<<20 lines to a terminal or a file or we're in trouble
      //  std::cout << "keysync->keyin=" << bin(i) << ", keysync->keyout=" << padbin(keysync->keyout, 5) << " but expected " << bin(bits) << std::endl;
      total_subtests++;
      // keysync->keyclk MUST be the output of a flip-flop
      // that only changes after two clock cycles.  Here's one clock cycle...
      if (keysync->keyclk == 0)
        passed_subtests++;
      total_subtests++;
      // First clock cycle...
      cycle_clock(keysync.get());
      if (keysync->keyclk == 0)
        passed_subtests++;
      total_subtests++;
      // Second clock cycle...
      cycle_clock(keysync.get());
      // So now keyclk MUST be 1.
      if (keysync->keyclk == 1)
        passed_subtests++;
      total_subtests++;
      // When we "release" our button, keyclk must return to zero
      // again after two clock cycles.  one clock cycle...
      keysync->keyin = 0;
      cycle_clock(keysync.get());
      if (keysync->keyclk == 1)
        passed_subtests++;
      total_subtests++;
      // And now keyclk should be zero.
      cycle_clock(keysync.get());
      if (keysync->keyclk == 0)
        passed_subtests++;
      total_subtests++;
    }
  #elif defined(SEQUENCE_SR)
    std::cout << "Testing sequence_sr...\n";
    const std::unique_ptr<Vsequence_sr> sequence_sr {new Vsequence_sr {contextp.get(), "SEQUENCE_SR"} };
    sequence_sr->trace(tfp, 99);
    tfp->open("sequence_sr.fst");
    sequence_sr->clk = 0;
    sequence_sr->rst = 0;
    sequence_sr->en = 0;
    sequence_sr->button = 0;
    // cycle reset
    std::cout << "Testing power-on reset.\n";
    eval(sequence_sr.get());
    sequence_sr->rst = 1;
    eval(sequence_sr.get());
    sequence_sr->rst = 0;
    eval(sequence_sr.get());
    total_subtests++;
    if (sequence_sr->seq == 0)
      passed_subtests++;
    else
      std::cout << "seq = " << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0\n";
    // clock with no enable
    std::cout << "Testing clock rising edge with enable=0, button=0.\n";
    cycle_clock(sequence_sr.get());
    total_subtests++;
    if (sequence_sr->seq == 0)
      passed_subtests++;
    else
      std::cout << "seq = " << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0\n";
    // clock with enable=1, button=0
    std::cout << "Testing clock rising edge with enable=1, button=0.\n";
    sequence_sr->en = 1;
    cycle_clock(sequence_sr.get());
    total_subtests++;
    if (sequence_sr->seq == 0)
      passed_subtests++;
    else
      std::cout << "seq = 0b" << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0b0\n";
    // clock with enable=1, button=1
    std::cout << "Testing clock rising edge with enable=1, button=1.\n";
    sequence_sr->button = 1;
    cycle_clock(sequence_sr.get());
    total_subtests++;
    if (sequence_sr->seq == 1)
      passed_subtests++;
    else
      std::cout << "seq = 0b" << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0b1\n";
    // push in full bit pattern 0b11110000 (1 is already in seq)
    std::cout << "Testing clock rising edge with enable=1, button=1, seq=1, push in 0b11110000.\n";
    int bits = 0b1110000;
    int seq = 0b1;
    for (int i = 6; i >= 0; i--) {
      total_subtests++;
      seq = ((seq << 1) | pin(bits, i)) & 0xFF;
      sequence_sr->button = pin(bits, i);
      cycle_clock(sequence_sr.get());
      if ((sequence_sr->seq & 0xFF) == seq)
        passed_subtests++;
      else
        std::cout << "seq = 0b" << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0b" << bin(seq) << "\n";
    }
    // disable and clock
    std::cout << "Testing clock rising edge with enable=0, button=1, seq=0b11110000.\n";
    sequence_sr->en = 0;
    cycle_clock(sequence_sr.get());
    total_subtests++;
    if ((sequence_sr->seq & 0xFF) == 0xF0)
      passed_subtests++;
    else
      std::cout << "seq = 0b" << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0b11110000\n";
    // reset
    std::cout << "Testing post-operation reset.\n";
    sequence_sr->rst = 1;
    cycle_clock(sequence_sr.get());
    total_subtests++;
    if ((sequence_sr->seq & 0xFF) == 0)
      passed_subtests++;
    else
      std::cout << "seq = 0b" << padbin(sequence_sr->seq & 0xFF, 8) << ", expected 0b0\n";
  #elif defined(FSM)
    // create array of strings to represent state_t
    state_t lockstate;
    std::cout << "Testing fsm...\n";
    const std::unique_ptr<Vfsm> fsm {new Vfsm {contextp.get(), "FSM"} };
    fsm->trace(tfp, 99);
    tfp->open("fsm.fst");
    
    fsm->clk = 0;
    fsm->rst = 0;
    fsm->keyout = 0;
    fsm->seq = 0;
    eval(fsm.get());

    std::cout << "Testing power-on reset.\n";
    fsm->rst = 1; eval(fsm.get());
    fsm->rst = 0; eval(fsm.get());
    total_subtests++;
    if (fsm->state == INIT)
      passed_subtests++;
    else
      std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(INIT) << "\n";
    
    // set our seq to be 10101010
    std::cout << "Setting seq to 0b10101010 and pressing W to secure the lock.\n";
    fsm->seq = 0b10101010;
    fsm->keyout = 16;
    eval(fsm.get());
    cycle_clock(fsm.get());
    total_subtests++;
    if (fsm->state == LS0)
      passed_subtests++;
    else
      std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(OPEN) << "\n";
    
    // enter our sequence one by one
    std::cout << "Entering sequence 0b10101010 one bit at a time.\n";
    for (int i = 0; i < 7; i++) {
      fsm->keyout = pin(0b10101010, 7-i);
      eval(fsm.get());
      cycle_clock(fsm.get());
      total_subtests++;
      if (fsm->state == LS1 + i)
        passed_subtests++;
      else
        std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(LS1 + i) << "\n";
    }
    // enter last bit and check for open
    fsm->keyout = pin(0b10101010, 7-7);
    eval(fsm.get());
    cycle_clock(fsm.get());
    total_subtests++;
    if (fsm->state == OPEN)
      passed_subtests++;
    else
      std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(OPEN) << "\n";
    
    // relock
    std::cout << "Relocking by pressing W.\n";
    fsm->keyout = 16;
    eval(fsm.get());
    cycle_clock(fsm.get());
    total_subtests++;
    if (fsm->state == LS0)
      passed_subtests++;
    else
      std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(LS0) << "\n";

    // enter wrong sequence
    std::cout << "Entering wrong sequence 0b10101110.\n";
    for (int i = 0; i < 5; i++) {
      fsm->keyout = pin(0b10101110, 7-i);
      eval(fsm.get());
      cycle_clock(fsm.get());
      total_subtests++;
      if (fsm->state == LS1 + i)
        passed_subtests++;
      else
        std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(LS1 + i) << "\n";
    }
    // enter last bit and check for alarm
    fsm->keyout = pin(0b10101110, 7-5);
    eval(fsm.get());
    cycle_clock(fsm.get());
    total_subtests++;
    if (fsm->state == ALARM)
      passed_subtests++;
    else
      std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(ALARM) << "\n";

    // reset and check for INIT
    std::cout << "Resetting and checking for INIT.\n";
    fsm->rst = 1; eval(fsm.get());
    fsm->rst = 0; eval(fsm.get());
    total_subtests++;
    if (fsm->state == INIT)
      passed_subtests++;
    else
      std::cout << "state = " << get_state_names(fsm->state) << ", expected " << get_state_names(INIT) << "\n";
  #elif defined(DISPLAY)
    std::cout << "Testing display...\n";
    const std::unique_ptr<Vdisplay> display {new Vdisplay {contextp.get(), "DISPLAY"} };
    display->trace(tfp, 99);
    tfp->open("display.fst");
    display->state = INIT;
    display->hzX = 0;
    // outputs are 64-bit ss and red, green, blue
    // test power-on reset
    std::cout << "Testing state == INIT, all LEDs should be off.\n";
    eval(display.get());
    exp_ss = 0; exp_green = 0; exp_blue = 0; exp_red = 0;
    check_outputs(display.get(), &passed_subtests, &total_subtests);
    // test state == OPEN
    std::cout << "Testing state == OPEN, ss should show OPEN and green == 1.\n";    
    display->state = OPEN;
    display->hzX = 0;
    eval(display.get());
    exp_ss = m_open; exp_green = 1; exp_blue = 0; exp_red = 0;
    check_outputs(display.get(), &passed_subtests, &total_subtests);

    // test state == ALARM
    std::cout << "Testing state == ALARM, ss should be ALARM and red == hzX.\n";
    display->state = ALARM;
    display->hzX = 1;
    eval(display.get());
    std::cout << "Setting hzX to 1...\n";
    exp_ss = m_alarm; exp_green = 0; exp_blue = 0; exp_red = display->hzX;
    check_outputs(display.get(), &passed_subtests, &total_subtests);
    std::cout << "Setting hzX to 0...\n";
    display->hzX = 0;
    eval(display.get());
    exp_ss = m_alarm; exp_green = 0; exp_blue = 0; exp_red = display->hzX;
    check_outputs(display.get(), &passed_subtests, &total_subtests);
    // test state == LS0, LS1, LS2 ... LS7
    std::cout << "Testing LSx states, ss should show SECURE with the corresponding decimal point turned on.\n";
    for (int i = 0; i < 8; i++) {
      display->state = LS0 + i;
      std::cout << "Entering state " << get_state_names(display->state) << "\n";
      eval(display.get());
      exp_ss = (1ULL << (((8 - (display->state & 0x7)) << 3) - 1));
      exp_ss |= m_secure;
      exp_green = 0; exp_blue = 1; exp_red = 0;
      check_outputs(display.get(), &passed_subtests, &total_subtests);
    }
    eval(display.get());
    eval(display.get());
    
  #elif defined(TOPMOD)
    std::cout << "Testing whole lock in top module...\n";
    const std::unique_ptr<Vtop> top {new Vtop {contextp.get(), "TOP"} };
    top->trace(tfp, 99);
    tfp->open("top.fst");
    top->hz100 = 0;
    top->reset = 0;
    top->pb = 0;
    eval(top.get());
    // cycle reset
    cycle_reset(top.get());
    exp_ss = 0; exp_right = 0; 
    exp_g = 0; exp_b = 0; exp_r = 0;
    std::cout << "Testing power-on reset.\n";
    check_outputs(top.get(), &passed_subtests, &total_subtests);
    // send in bit pattern 10101100
    std::cout << "\nTesting good combination.\n";
    int pattern = 0b10101101;
    std::cout << "Sending in bit pattern 0b10101101.\n";
    for (uint8_t bits = 0b10110101; bits > 0; bits >>= 1) {
      assert_key(top.get(), 1 << (bits & 1));
      exp_right = ((exp_right << 1) | (bits & 1)) & 0xFF;
      check_outputs(top.get(), &passed_subtests, &total_subtests);
    }
    std::cout << "Pressed W to save 1010 1101.\n";
    // Press W
    assert_key(top.get(), 1 << 16);
    // SeCUrE with ss7[7] = 1
    exp_ss = 0x80006d79393e5079;
    exp_b = 1;
    check_outputs(top.get(), &passed_subtests, &total_subtests);
    // Apply ~mask to exp_ss to remove ss0[7], shift mask by 8, 
    // then apply mask to move 1 to ss1[7]
    uint64_t mask = 0x8000000000000000;
    for (int i = 7; i >= 0; i--) {
      std::cout << "Pressing " << std::dec << (pin(pattern, i) & 0x1) << "...\n";
      assert_key(top.get(), 1 << pin(pattern, i));
      // std::cout << "Applying mask " << bin(~mask) << "\n";
      exp_ss &= ~mask;
      mask >>= 8;
      // std::cout << "Applying mask " << bin(mask) << "\n";
      exp_ss |= mask;
      if (i == 0) {
        // we should now see OPEN
        exp_ss = 0x3f737954;
        exp_g = 1;
        exp_b = 0;
        std::cout << "Expecting OPEN...\n";
      }
      check_outputs(top.get(), &passed_subtests, &total_subtests);
    }
    // Relock by pressing W
    std::cout << "\nTesting bad combination.\n";
    std::cout << "Pressing W to relock and show SECURE with correct decimal point lit.\n";
    assert_key(top.get(), 1 << 16);
    exp_ss = 0x80006d79393e5079;
    exp_b = 1; exp_g = 0;
    check_outputs(top.get(), &passed_subtests, &total_subtests);    
    // Send in 11
    std::cout << "Sending in 1 (correct bit).\n";
    assert_key(top.get(), 1 << 1);
    exp_ss = 0x806d79393e5079;
    check_outputs(top.get(), &passed_subtests, &total_subtests);    
    std::cout << "Sending in 1 (now wrong bit).\n";
    assert_key(top.get(), 1 << 1);
    exp_b = 0;
    exp_r = 1;
    exp_ss = 0x3977383800670606;
    check_outputs(top.get(), &passed_subtests, &total_subtests);    
    // cycle clock 100 times, and count how many times red is on
    std::cout << "Cycling clock 100 times.\n";
    int red_high = 0;
    for (int i = 0; i < 100; i++) {
      cycle_clock(top.get());
      if (top->red == 1)
        red_high++;
    }
    total_subtests++;
    if (red_high >= 50) {
      std::cout << "PASS: Out of 100 clock cycles of hz100, red was high " << std::to_string(red_high) << " times.\n";
      passed_subtests++;
    } else {
      std::cout << "FAIL: Red was high " << std::to_string(red_high) << " times, expected at least 50.  Check the value passed to lim.\n";
    }
  #endif

  tfp->close();
  tfp = nullptr;
  
  update_tests(passed_subtests, total_subtests, "1");
  /***********************************/

  passed_subtests = 0;
  total_subtests = 0;

  /***********************************/
  // END TESTS
  /*************************************************************************/

  // good to have to detect bugs
  assert(passed_test_count <= total_test_count);

  if (passed_test_count == total_test_count)
  {
    std::cout << "ALL " << std::to_string(total_test_count) << " TESTS PASSED"
              << "\n";
  }
  else
  {
    std::cout << "ERROR: " << std::to_string(passed_test_count) << "/" << std::to_string(total_test_count) << " tests passed.\n";
  }

  // Fin
  return 0;
}
