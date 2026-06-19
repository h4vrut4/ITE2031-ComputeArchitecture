#include "BP.h"

// 초기화
BranchPredictor::BranchPredictor() {
    for (int i = 0; i < BTB_SIZE; ++i) {
        btb[i].state = BTB_EMPTY;
        btb[i].tag = 0;
        btb[i].target = 0;
    }
    for (int i = 0; i < PHT_SIZE; ++i){
        pht[i] = WEAKLY_NOT_TAKEN;
    }
}

// 예측 함수
bool BranchPredictor::predict(uint32_t pc, uint32_t &nextPC) { //이게 다음거 예측하는거 아닌가?
    uint32_t BTBIndex = getBTBIndex(pc);
    uint32_t PHTIndex = getPHTIndex(pc);
    uint32_t tag = getTag(pc);

    const BTBEntry &entry = btb[BTBIndex];

    if (entry.state == BTB_EMPTY || entry.tag != tag){
        nextPC = pc + 4;
        return false;  // BTB Miss → predict not taken
    }

    // BTB Hit
    if (entry.state == BTB_BRANCH) {
        // Branch → PHT 확인
        if (pht[PHTIndex] >= WEAKLY_TAKEN) {
            nextPC = entry.target;
            return true;  // predict taken
        } else {
            nextPC = pc + 4;// PC? PC+4?
            return false; // predict not taken
        }
    } else if (entry.state == BTB_JUMP) {
        // Jump는 무조건 taken
        nextPC = entry.target;
        return true;
    }

    // 혹시라도 잘못된 상태
    nextPC = pc + 4;
    return false;
}



// 업데이트 함수
//predict에서 tag매치가 안되면 -> 그냥 PC+4를 next_PC로 내뱉으니까
//update도 Branch또는 Jump일때만 해주는게 맞는데?
void BranchPredictor::update(uint32_t pc, bool taken, uint32_t actual_target, bool isBranch) { //이게 BTB 업데이트인데
    uint32_t BTBIndex = getBTBIndex(pc);
    uint32_t PHTIndex = getPHTIndex(pc);
    uint32_t tag = getTag(pc);

    // BTB 업데이트
    btb[BTBIndex].state = isBranch ? BTB_BRANCH : BTB_JUMP;
    btb[BTBIndex].tag = tag;
    btb[BTBIndex].target = actual_target;

    // PHT는 branch에만 적용
    if (isBranch) {
        updatePHT(PHTIndex, taken);
    }
}
void BranchPredictor::updatePHT(uint32_t index, bool taken) {
    PHTState &state = pht[index];
    if (taken) {
        if (state < STRONGLY_TAKEN) state = static_cast<PHTState>(state + 1);
    } else {
        if (state > STRONGLY_NOT_TAKEN) state = static_cast<PHTState>(state - 1);
    }
}



// 내부 유틸 함수들
uint32_t BranchPredictor::getBTBIndex(uint32_t pc) {
    return (pc >> 2) & 0x3F;  // 6-bit index: PC[7:2]
}
uint32_t BranchPredictor::getPHTIndex(uint32_t pc) {
    return (pc >> 2) & 0xFF;  // 8-bit index: PC[9:2]
}
uint32_t BranchPredictor::getTag(uint32_t pc) {
    return pc >> 8;  // 24-bit tag: PC[31:8]
}

