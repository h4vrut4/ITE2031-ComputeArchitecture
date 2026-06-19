#ifndef BP_H
#define BP_H
#include <cstdint>

// BTB Entry 구조체
enum BTBState {
    BTB_EMPTY   = 0,  // Not initialized
    BTB_JUMP    = 1,  // Jump (j, jal)
    BTB_BRANCH  = 2   // Conditional Branch (beq, bne)
};

struct BTBEntry {
    BTBState state;   // 0: empty, 1: jump, 2: branch
    uint32_t tag;     // PC[31:8]
    uint32_t target;  // predicted target
};


// 2-bit PHT (Pattern History Table) counter
enum PHTState {
    STRONGLY_NOT_TAKEN = 0,
    WEAKLY_NOT_TAKEN   = 1,
    WEAKLY_TAKEN       = 2,
    STRONGLY_TAKEN     = 3
};

class BranchPredictor {
public:
    BranchPredictor();

    // 예측 관련 함수
    bool predict(uint32_t pc, uint32_t &nextPC);
    void update(uint32_t pc, bool taken, uint32_t actual_target, bool isBranch); //BTB, PHT 둘 다 업데이트 하는 함수.

private:
    static const int BTB_SIZE = 64;   // 6-bit index → 64-entry
    static const int PHT_SIZE = 256;
    BTBEntry btb[BTB_SIZE];
    PHTState pht[PHT_SIZE];

    uint32_t getBTBIndex(uint32_t pc);
    uint32_t getPHTIndex(uint32_t pc);
    uint32_t getTag(uint32_t pc);
    void updatePHT(uint32_t index, bool taken);
};
#endif