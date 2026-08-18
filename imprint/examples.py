"""Generate the reference examples. Run: python3 examples.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from imprint import render, Engagement as E

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "examples")

DEV   = (3, 1, 2, 2, 4, 1, 4)
LEAD  = (4, 3, 3, 3, 4, 3, 3)
SHOP  = (2, 1, 2, 5, 2, 1, 2)
NIGHT = (2, 0, 3, 1, 2, 0, 3)
NURSE = (3, 2, 5, 4, 4, 1, 2)
WARE  = (1, 0, 2, 1, 1, 0, 2)

CASES = {
    # provenance states
    "01-new-signup":            [],
    "02-resume-imported":       [E(0,18,"self_asserted"), E(18,44,"self_asserted"),
                                 E(44,66,"self_asserted"), E(66,96,"self_asserted")],
    "03-employment-verified":   [E(0,18,"employment_verified"), E(18,44,"employment_verified"),
                                 E(44,66,"employment_verified"), E(66,96,"employment_verified")],
    "04-first-attestation":     [E(0,18,"employment_verified"),
                                 E(18,44,"party_attested",DEV,"multi"),
                                 E(44,66,"employment_verified"), E(66,96,"self_asserted")],
    "05-fully-attested":        [E(0,18,"party_attested",WARE,"multi"),
                                 E(18,44,"party_attested",DEV,"multi"),
                                 E(44,66,"party_attested",LEAD,"single"),
                                 E(66,96,"party_attested",LEAD,"multi")],
    "06-peer-attested-only":    [E(0,26,"peer_attested",SHOP,None),
                                 E(26,52,"peer_attested",NIGHT,None)],
    # time structure
    "07-sequential":            [E(0,24,"party_attested",DEV,"multi"),
                                 E(24,48,"party_attested",LEAD,"single")],
    "08-overlapping":           [E(0,30,"party_attested",DEV,"multi"),
                                 E(18,48,"party_attested",LEAD,"single")],
    "09-gig-concurrent":        [E(0,30,"party_attested",SHOP,"single"),
                                 E(4,26,"peer_attested",NIGHT,None),
                                 E(10,30,"party_attested",DEV,"multi"),
                                 E(30,44,"party_attested",DEV,"multi")],
    "10-with-a-gap":            [E(0,22,"party_attested",DEV,"multi"),
                                 E(36,60,"party_attested",LEAD,"multi")],
    "11-long-career":           [E(i*26,(i+1)*26,"party_attested",
                                   (min(6,1+i),min(6,i),min(6,1+i),2,min(6,1+i),min(6,i),2),
                                   "multi" if i%3 else "single") for i in range(9)],
    # occupational profiles, one chapter each, everything else identical
    "12-profile-warehouse":     [E(0,36,"party_attested",WARE,"multi")],
    "13-profile-nurse":         [E(0,36,"party_attested",NURSE,"multi")],
    "14-profile-shop":          [E(0,36,"party_attested",SHOP,"multi")],
}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, record in CASES.items():
        with open(os.path.join(OUT, name + ".svg"), "w") as fh:
            fh.write(render(record))
    print("wrote %d examples to %s" % (len(CASES), OUT))
