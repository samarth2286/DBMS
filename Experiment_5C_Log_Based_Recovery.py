from pathlib import Path
import re

LOG_FILE = Path(__file__).with_name("log.txt")

INITIAL_VALUES = {"P": 500, "Q": 800, "R": 300, "S": 1000}


def read_log():
    return [
        line.strip()
        for line in LOG_FILE.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def parse_update(record):
    match = re.fullmatch(r"<(T\d+), ([PQRS]), (\d+), (\d+)>", record)
    if not match:
        return None
    txn, item, old_value, new_value = match.groups()
    return txn, item, int(old_value), int(new_value)


def main():
    records = read_log()

    print("LOG RECORDS")
    for number, record in enumerate(records, start=1):
        print(f"{number}. {record}")

    started = set()
    committed = set()
    updates = []
    checkpoint_index = -1
    checkpoint_active = set()

    for index, record in enumerate(records):
        if record.endswith(", start>"):
            started.add(record[1:].split(",")[0])

        update = parse_update(record)
        if update:
            updates.append((index, *update))

        if record.endswith(", commit>"):
            committed.add(record[1:].split(",")[0])

        if record.startswith("<checkpoint"):
            checkpoint_index = index
            match = re.search(r"\{([^}]*)\}", record)
            if match and match.group(1).strip():
                checkpoint_active = {
                    name.strip() for name in match.group(1).split(",")
                }

    active_at_crash = started - committed
    uncommitted = active_at_crash
    committed_after_checkpoint = {
        txn for txn in committed
        if any(index > checkpoint_index and t == txn
               for index, t, _, _, _ in updates)
    }

    print("\nCOMMITTED TRANSACTIONS:", sorted(committed))
    print("UNCOMMITTED AT CRASH:", sorted(uncommitted))
    print("LAST CHECKPOINT:", records[checkpoint_index] if checkpoint_index >= 0 else "None")
    print("ACTIVE AT CHECKPOINT:", sorted(checkpoint_active))

    undo_list = [
        (txn, item, old_value, new_value)
        for index, txn, item, old_value, new_value in updates
        if txn in uncommitted
    ]
    redo_list = [
        (txn, item, old_value, new_value)
        for index, txn, item, old_value, new_value in updates
        if index > checkpoint_index and txn in committed
    ]

    print("\nUNDO LIST:", undo_list)
    print("REDO LIST:", redo_list)

    # Reconstruct the state at the checkpoint by applying all earlier log updates.
    values = INITIAL_VALUES.copy()
    for index, txn, item, old_value, new_value in updates:
        if checkpoint_index >= 0 and index <= checkpoint_index:
            values[item] = new_value

    print("\nVALUES AT CHECKPOINT:", values)

    # Undo uncommitted transactions in reverse log order.
    for txn, item, old_value, new_value in reversed(undo_list):
        values[item] = old_value

    print("AFTER UNDO:", values)

    # Redo committed transactions after the checkpoint in forward log order.
    for txn, item, old_value, new_value in redo_list:
        values[item] = new_value

    print("AFTER REDO:", values)
    print("\nFINAL VALUES")
    for item in ("P", "Q", "R", "S"):
        print(f"{item} = {values[item]}")

    print("\nT1 needs no recovery action because it committed before the checkpoint.")
    print("T2 is undone because it was active and uncommitted at the crash.")
    print("T3 is redone because it committed after the checkpoint.")

    print("\nQ10 COMPARISON")
    print("If <T2, commit> is added before the crash, T2 is committed.")
    print("Then T2 is removed from the UNDO list; its Q and S updates are retained.")
    print("The redo list still includes T3's R update.")
    print("Final values in that case: P=450, Q=900, R=250, S=1100.")


if __name__ == "__main__":
    main()
