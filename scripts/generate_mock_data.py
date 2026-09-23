"""
Generate synthetic sports-business data for the stewardship demo.

All data is fake. Known data quality issues are injected ON PURPOSE so the
dbt tests and stewardship workflow have something real to catch.

Run:  python scripts/generate_mock_data.py
Writes CSVs into ./seeds/
"""
import csv
import random
from datetime import date, datetime, timedelta
from pathlib import Path

random.seed(42)
OUT = Path(__file__).resolve().parent.parent / "seeds"
OUT.mkdir(exist_ok=True)

# ---------------------------------------------------------------------------
# Reference data
# ---------------------------------------------------------------------------
SEASON_START = date(2025, 10, 22)
HOME_GAMES = [SEASON_START + timedelta(days=4 * i) for i in range(41)]  # 41 home dates
SECTIONS = {"100": (95, 260), "200": (45, 120), "COURTSIDE": (900, 2500), "LOGE": (180, 400)}
CUSTOMERS = [f"C{str(i).zfill(5)}" for i in range(1, 601)]

N_TICKETS = 2000
N_DUP_TICKETS = 15
N_NULL_PRICE = 20
N_NULL_CUSTOMER = 10
N_BAD_SECTION = 4

SPONSOR_CUTOFF = date(2026, 1, 31)  # vendor feed "stopped" here -> stale data


def write(name, header, rows):
    with open(OUT / name, "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)
    return len(rows)


# ---------------------------------------------------------------------------
# 1. Ticket sales
# ---------------------------------------------------------------------------
tickets = []
for i in range(1, N_TICKETS + 1):
    game = random.choice(HOME_GAMES)
    section = random.choice(list(SECTIONS))
    lo, hi = SECTIONS[section]
    price = round(random.uniform(lo, hi), 2)
    purchased = datetime.combine(game, datetime.min.time()) - timedelta(
        days=random.randint(0, 60), minutes=random.randint(0, 1439)
    )
    tickets.append([f"T{str(i).zfill(6)}", game.isoformat(), section, price,
                    purchased.isoformat(sep=" "), random.choice(CUSTOMERS)])

for row in random.sample(tickets, N_NULL_PRICE):
    row[3] = ""                                   # missing price
for row in random.sample(tickets, N_NULL_CUSTOMER):
    row[5] = ""                                   # missing customer
for row in random.sample(tickets, N_BAD_SECTION):
    row[2] = random.choice(["sec 100", "Loge ", "200 "])  # inconsistent labels

vendor_ticket_count = len(tickets)                # what the vendor SAYS it sent
tickets += random.sample(tickets, N_DUP_TICKETS)  # duplicate rows from a re-send
random.shuffle(tickets)
n_tix = write("raw_ticket_sales.csv",
              ["ticket_id", "game_date", "section", "price", "purchase_timestamp", "customer_id"],
              tickets)

# ---------------------------------------------------------------------------
# 2. Campaign sends
# ---------------------------------------------------------------------------
CAMPAIGNS = {
    "CMP-2501": date(2025, 10, 1), "CMP-2502": date(2025, 11, 15),
    "CMP-2503": date(2025, 12, 20), "CMP-2601": date(2026, 1, 20),
    "CMP-2602": date(2026, 3, 1),
}
sends, sid = [], 1
for cid, sent in CAMPAIGNS.items():
    for cust in random.sample(CUSTOMERS, 300):
        opened = 1 if random.random() < 0.38 else 0
        clicked = 1 if opened and random.random() < 0.22 else 0
        sends.append([f"S{str(sid).zfill(6)}", cid, cust, sent.isoformat(), opened, clicked])
        sid += 1
for row in random.sample([r for r in sends if r[4] == 0], 7):
    row[5] = 1                                    # clicked but never opened: logically suspect
n_sends = write("raw_campaign_sends.csv",
                ["send_id", "campaign_id", "customer_id", "email_sent_date", "opened_flag", "clicked_flag"],
                sends)

# ---------------------------------------------------------------------------
# 3. Sponsorship impressions (feed stops early -> stale)
# ---------------------------------------------------------------------------
ASSETS = {"Jersey Patch": (900_000, 0.012), "Courtside LED": (650_000, 0.009),
          "Arena Concourse Signage": (120_000, 0.004), "Scoreboard Feature": (400_000, 0.007)}
imps = []
for game in [g for g in HOME_GAMES if g <= SPONSOR_CUTOFF]:
    for asset, (base, cpm_val) in ASSETS.items():
        impressions = int(base * random.uniform(0.7, 1.3))
        imps.append([asset, game.isoformat(), impressions, round(impressions * cpm_val, 2)])
random.choice(imps)[3] = ""                       # one missing valuation
n_imps = write("raw_sponsorship_impressions.csv",
               ["asset_name", "game_date", "broadcast_impressions", "estimated_value"], imps)

# ---------------------------------------------------------------------------
# 4. Vendor manifest: row counts each vendor CLAIMS it delivered
# ---------------------------------------------------------------------------
write("vendor_file_manifest.csv", ["file_name", "expected_row_count", "delivered_on"], [
    ["raw_ticket_sales", vendor_ticket_count, "2026-04-15"],
    ["raw_campaign_sends", n_sends, "2026-04-15"],
    ["raw_sponsorship_impressions", n_imps, "2026-04-15"],
])

print(f"tickets={n_tix} (vendor claims {vendor_ticket_count}), sends={n_sends}, impressions={n_imps}")
