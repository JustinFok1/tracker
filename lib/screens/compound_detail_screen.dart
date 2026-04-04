import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/compound.dart';
import 'add_vial_screen.dart';

class CompoundDetailScreen extends StatelessWidget {
  final Compound compound;

  const CompoundDetailScreen({super.key, required this.compound});

  Color _categoryColor(String category) {
    switch (category) {
      case 'Peptide':        return Colors.tealAccent;
      case 'Hormone':        return Colors.orangeAccent;
      case 'Secretagogue':   return Colors.purpleAccent;
      case 'Oral Steroid':   return Colors.pinkAccent;
      default:               return Colors.purple;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Peptide':        return Icons.biotech;
      case 'Hormone':        return Icons.bolt;
      case 'Secretagogue':   return Icons.trending_up;
      case 'Oral Steroid':   return Icons.medication;
      default:               return Icons.science;
    }
  }

  // Static compound data
  Map<String, String> _getDetails() {
    switch (compound.name) {
      case 'BPC-157':
        return {
          'Dosage':    '200–500 mcg/day',
          'Half-life': '~4 hours',
          'Frequency': 'Once or twice daily',
          'Route':     'Subcutaneous or IM injection',
          'Notes':     'Most versatile healing peptide. For injuries, inject subcutaneously near the site of damage. For gut healing (leaky gut, IBD, GERD), oral or sublingual dosing may be more effective. Stable at room temp once reconstituted. Stack with TB-500 for enhanced systemic + local healing. No known side effects at research doses.',
        };
      case 'TB-500':
        return {
          'Dosage':    '2–2.5 mg, twice in week one, then 2–2.5 mg/week',
          'Half-life': '~5–6 days',
          'Frequency': 'Twice weekly (loading), once weekly (maintenance)',
          'Route':     'Subcutaneous injection',
          'Notes':     'Systemic peptide — promotes actin upregulation and cellular migration for repair. No need to inject near injury. Loading phase: 2 injections/week for 4–6 weeks. Maintenance: 1 injection/week. Often stacked with BPC-157. Well tolerated with minimal reported side effects.',
        };
      case 'Ipamorelin':
        return {
          'Dosage':    '200–300 mcg/injection',
          'Half-life': '~2 hours',
          'Frequency': '2–3x daily, fasted',
          'Route':     'Subcutaneous injection',
          'Notes':     'Most selective GHRP — minimal cortisol and prolactin elevation. No significant hunger spike. Best results when stacked with CJC-1295. Inject before bed and upon waking for optimal GH pulse timing.',
        };
      case 'CJC-1295':
        return {
          'Dosage':    'w/ DAC: 1–2 mg/week  |  No DAC: 100–300 mcg/injection',
          'Half-life': 'w/ DAC: ~8 days  |  No DAC: ~30 minutes',
          'Frequency': 'w/ DAC: Once or twice weekly  |  No DAC: With each GHRP dose',
          'Route':     'Subcutaneous injection',
          'Notes':     'CJC-1295 w/ DAC causes a sustained "GH bleed" — steady elevation. Mod GRF 1-29 (no DAC) creates physiological pulses and is preferred by most researchers. Always stack with a GHRP (Ipamorelin, GHRP-2) for synergistic GH release.',
        };
      case 'Sermorelin':
        return {
          'Dosage':    '200–500 mcg/day',
          'Half-life': '~10–20 minutes',
          'Frequency': 'Once daily before bed',
          'Route':     'Subcutaneous injection',
          'Notes':     'Most natural GH release profile — stimulates the pituitary rather than bypassing it. Preserves pituitary function over time. Often used as a clinical HRT alternative. Loses potency quickly once reconstituted — keep refrigerated.',
        };
      case 'GHRP-2':
        return {
          'Dosage':    '100–300 mcg/injection',
          'Half-life': '~30 minutes',
          'Frequency': '2–3x daily, fasted',
          'Route':     'Subcutaneous injection',
          'Notes':     'More potent GH release than GHRP-6 but also elevates cortisol and prolactin. Moderate hunger stimulation. Stack with CJC-1295 or Sermorelin for amplified GH release. Inject 30–60 min before food.',
        };
      case 'GHRP-6':
        return {
          'Dosage':    '100–300 mcg/injection',
          'Half-life': '~15–20 minutes',
          'Frequency': '2–3x daily, fasted',
          'Route':     'Subcutaneous injection',
          'Notes':     'Causes a strong hunger spike ~20 min post-injection — useful on a bulk, problematic on a cut. Elevates cortisol and prolactin more than Ipamorelin. Stack with a GHRH for synergy. First-generation GHRP.',
        };
      case 'PT-141':
        return {
          'Dosage':    '1–2 mg/use',
          'Half-life': '~2.7 hours',
          'Frequency': 'As needed, 30–60 min before activity',
          'Route':     'Subcutaneous injection or nasal spray',
          'Notes':     'Acts centrally on melanocortin receptors in the brain — works regardless of blood flow (unlike PDE5 inhibitors). Effective in both men and women. Common sides: nausea, facial flushing, spontaneous erections. Start at 0.5 mg to assess tolerance.',
        };
      case 'Melanotan II':
        return {
          'Dosage':    '0.25–1 mg/injection',
          'Half-life': '~1 hour',
          'Frequency': 'Daily during loading, then as needed',
          'Route':     'Subcutaneous injection',
          'Notes':     'Causes significant skin darkening without UV exposure. Also increases libido and suppresses appetite. Start with 0.25 mg to assess tolerance (nausea, flushing, facial redness are common). Loading phase: 1–2 weeks daily, then maintenance dosing.',
        };
      case 'HGH Frag':
        return {
          'Dosage':    '200–500 mcg/day',
          'Half-life': '~30 minutes',
          'Frequency': '1–2x daily, fasted',
          'Route':     'Subcutaneous injection',
          'Notes':     'Does not raise IGF-1, does not cause insulin resistance. Targets lipolysis directly in adipose tissue. Best injected fasted (morning and/or pre-workout) for maximum effect. Does not produce the anabolic effects of full HGH.',
        };
      case 'IGF-1 LR3':
        return {
          'Dosage':    '20–100 mcg/day',
          'Half-life': '~20–30 hours',
          'Frequency': 'Once daily, post-workout',
          'Route':     'Intramuscular or subcutaneous injection',
          'Notes':     'Promotes muscle cell hyperplasia (new cell creation) — not just hypertrophy. Hypoglycemia risk — always have fast-acting carbs on hand. Run in cycles of 4–6 weeks. Do not inject before bed. Requires careful dosing — start at 20–40 mcg.',
        };
      case 'Epithalon':
        return {
          'Dosage':    '5–10 mg/day',
          'Half-life': 'Short (exact unknown)',
          'Frequency': 'Once daily',
          'Route':     'Subcutaneous injection or intranasal',
          'Notes':     'Activates telomerase and may increase telomere length. Restores melatonin production in the pineal gland. Typical protocol: 10–20 day cycles, 1–2x per year. May improve sleep quality and immune function. Very low side-effect profile.',
        };
      case 'Thymosin Alpha-1':
        return {
          'Dosage':    '1.6 mg, 2x weekly',
          'Half-life': '~2 hours',
          'Frequency': 'Twice weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'Derived from the thymus gland — modulates and enhances T-cell activity. Used clinically for immune disorders, chronic infections, and post-illness recovery. Stacks well with BPC-157. Minimal side effects. Run for 4–12 week cycles.',
        };
      case 'GHK-Cu':
        return {
          'Dosage':    '1–2 mg/day (systemic) or topical as needed',
          'Half-life': 'Short (minutes, systemic)',
          'Frequency': 'Once daily',
          'Route':     'Subcutaneous injection or topical',
          'Notes':     'Stimulates collagen, elastin, and GAG synthesis. Promotes wound healing and has anti-inflammatory properties. Can be used topically for skin and hair. Systemic use targets connective tissue repair. Often stacked with BPC-157.',
        };
      case 'Selank':
        return {
          'Dosage':    '250–3000 mcg/day',
          'Half-life': '~1–2 minutes (intranasal)',
          'Frequency': '2–3x daily',
          'Route':     'Intranasal (primary) or subcutaneous injection',
          'Notes':     'Anxiolytic and mild nootropic — modulates GABA, serotonin, and BDNF. No tolerance, dependence, or withdrawal. Improves memory consolidation and reduces anxiety without sedation. Often stacked with Semax for a balanced cognitive/anxiety protocol.',
        };
      case 'Semax':
        return {
          'Dosage':    '200–900 mcg/day',
          'Half-life': '~1–2 minutes (intranasal)',
          'Frequency': '2–3x daily',
          'Route':     'Intranasal (primary)',
          'Notes':     'Upregulates BDNF — supports neuroprotection, memory, and focus. Derived from the ACTH sequence. Popular cognitive enhancer in Russia and Eastern Europe. May cause mild stimulation. Often stacked with Selank to balance stimulating effects with anxiolytic ones.',
        };
      case 'Tesamorelin':
        return {
          'Dosage':    '1–2 mg/day',
          'Half-life': '~26–38 minutes',
          'Frequency': 'Once daily',
          'Route':     'Subcutaneous injection',
          'Notes':     'More potent and stable than Sermorelin. FDA-approved (Egrifta) for HIV-associated visceral fat. Off-label use for body composition and cognitive benefits. Raises IGF-1. Keep refrigerated and use within 3 weeks of reconstitution.',
        };
      case 'Semaglutide':
        return {
          'Dosage':    '0.25–2.4 mg/week',
          'Half-life': '~7 days',
          'Frequency': 'Once weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'FDA-approved (Ozempic / Wegovy). Titrate slowly: start at 0.25 mg/week and increase every 4 weeks to minimize GI side effects (nausea, vomiting, constipation). Significant muscle loss risk — prioritize resistance training and high protein intake (1g+/lb). Do not increase dose if side effects are severe.',
        };
      case 'Tirzepatide':
        return {
          'Dosage':    '2.5–15 mg/week',
          'Half-life': '~5 days',
          'Frequency': 'Once weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'FDA-approved (Mounjaro / Zepbound). Dual GLP-1/GIP agonism provides superior metabolic benefit vs semaglutide — ~20–22% body weight reduction in trials. Titrate from 2.5 mg every 4 weeks. Same muscle preservation caveats as semaglutide. GIP agonism also has direct effects on adipose tissue.',
        };
      case 'Retatrutide':
        return {
          'Dosage':    '2–12 mg/week (trial doses)',
          'Half-life': '~6 days',
          'Frequency': 'Once weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'Next-generation triple agonist (GLP-1 + GIP + glucagon receptor). Phase 3 trials show greater weight loss than semaglutide or tirzepatide — up to 24%+ body weight reduction. Not yet FDA-approved. Glucagon agonism adds thermogenic fat-burning on top of appetite suppression.',
        };
      case 'Cagrilintide':
        return {
          'Dosage':    '0.16–4.5 mg/week (trial doses)',
          'Half-life': '~7–8 days',
          'Frequency': 'Once weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'Long-acting amylin analog — slows gastric emptying and blunts post-meal glucose spikes. Most studied in combination with semaglutide (CagriSema), which shows additive weight loss vs either alone. Not yet independently FDA-approved. Phase 3 trials ongoing.',
        };
      case 'Melanotan I':
        return {
          'Dosage':    '10–20 mg per implant or 0.5–1 mg/injection',
          'Half-life': '~1 hour',
          'Frequency': 'Every 1–3 days',
          'Route':     'Subcutaneous injection or implant (Scenesse)',
          'Notes':     'More selective than MT-2 — primarily activates MC1R for skin tanning with minimal effect on libido or appetite. FDA-approved as Scenesse for erythropoietic protoporphyria (EPP). Far fewer spontaneous erections and less nausea vs MT-2. Preferred for cosmetic tanning use.',
        };
      case 'KPV':
        return {
          'Dosage':    '100–500 mcg/day',
          'Half-life': 'Short (minutes)',
          'Frequency': 'Once or twice daily',
          'Route':     'Oral or subcutaneous injection',
          'Notes':     'C-terminal tripeptide fragment of alpha-MSH. Potent anti-inflammatory via NF-κB pathway inhibition. Crosses the intestinal epithelium — oral dosing is effective for gut inflammation (IBD, Crohn\'s, leaky gut). Often stacked with BPC-157 for synergistic gut healing. Very low toxicity profile.',
        };
      case 'VIP':
        return {
          'Dosage':    '25–50 mcg/day',
          'Half-life': '~2 minutes',
          'Frequency': 'Once or twice daily',
          'Route':     'Intranasal or intravenous',
          'Notes':     'Potent anti-inflammatory and immunomodulatory neuropeptide. Primary use in MCAS (mast cell activation syndrome) and CIRS (chronic inflammatory response syndrome). Vasodilatory — can cause transient hypotension, facial flushing, and warmth. Start very low and titrate carefully. Requires medical supervision for IV use.',
        };
      case 'Kisspeptin':
        return {
          'Dosage':    '1–10 mcg/kg per injection',
          'Half-life': 'KP-10: ~10 min / KP-54: ~30 min',
          'Frequency': 'Pulsatile, 2–3x daily',
          'Route':     'Subcutaneous or intravenous injection',
          'Notes':     'Activates the HPG axis by stimulating hypothalamic GnRH release, which drives LH/FSH and ultimately testosterone production. Used for hypogonadism, fertility support, and post-cycle hormonal recovery. Pulsatile administration is important — continuous exposure causes receptor desensitization.',
        };
      case 'MOTS-c':
        return {
          'Dosage':    '5–10 mg, 2–3x weekly',
          'Half-life': 'Unknown (short)',
          'Frequency': '2–3x weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'Encoded by mitochondrial DNA — one of few mitochondrial-derived peptides. Activates AMPK and promotes glucose uptake into muscle. Research suggests exercise-mimetic properties, improved insulin sensitivity, and anti-aging effects. Often stacked with other metabolic peptides (5-Amino-1MQ, NAD+). Still primarily in early research phase.',
        };
      case 'DSIP':
        return {
          'Dosage':    '100–200 mcg/day',
          'Half-life': '~15–20 minutes',
          'Frequency': 'Once daily, 30 min before sleep',
          'Route':     'Subcutaneous injection',
          'Notes':     'Promotes slow-wave delta sleep rather than general sedation — no next-day grogginess. May reduce basal cortisol and improve stress resilience. Effects can be cumulative over multiple doses. Used for insomnia, overtraining recovery, and cortisol management. Some research suggests effects on GH secretion during sleep.',
        };
      case 'NAD+':
        return {
          'Dosage':    'IV: 250–1000 mg/session  |  SubQ: 50–300 mg/day',
          'Half-life': 'Variable (cellular turnover ~9–10 hours)',
          'Frequency': 'IV: weekly or as needed  |  SubQ: daily',
          'Route':     'Intravenous or subcutaneous injection',
          'Notes':     'Not technically a peptide — essential coenzyme for cellular energy (ATP), DNA repair, and sirtuin activation. IV is most bioavailable but administer slowly to avoid flushing, nausea, and chest tightness. Oral precursors (NMN, NR) are practical for daily maintenance. Often combined with 5-Amino-1MQ for synergistic NAD+ elevation.',
        };
      case '5-Amino-1MQ':
        return {
          'Dosage':    '50–250 mg/day',
          'Half-life': '~5–7 hours',
          'Frequency': 'Once or twice daily',
          'Route':     'Oral',
          'Notes':     'Not technically a peptide — small molecule NNMT (nicotinamide N-methyltransferase) inhibitor. By blocking NNMT, it raises intracellular NAD+, activates SIRT1, and promotes lipolysis. May prevent pre-adipocyte differentiation into fat cells. Stack with NAD+ precursors (NMN, NR) for synergistic effect.',
        };
      case 'Wolverine Blend':
        return {
          'Dosage':    '250 mcg BPC-157 + 1.25 mg TB-500 per injection',
          'Half-life': 'Varies by component',
          'Frequency': 'Once or twice daily',
          'Route':     'Subcutaneous injection',
          'Notes':     'Combines localized repair (BPC-157) with systemic recovery (TB-500) for synergistic tissue healing. Named for rapid-healing association. Popular among athletes recovering from injury. Can inject near site of injury or systemically. Some blends also include GHK-Cu or Thymosin Alpha-1.',
        };
      case 'GLOW':
        return {
          'Dosage':    'Per clinic protocol (~1–2 mg total/day)',
          'Half-life': 'Varies by component',
          'Frequency': 'Once daily',
          'Route':     'Subcutaneous injection',
          'Notes':     'Proprietary aesthetic blend — formulation varies by clinic. Typically contains GHK-Cu, Epithalon, and/or Thymosin Alpha-1. Targets collagen synthesis, skin elasticity, and cellular anti-aging. Results most visible after 4–8 weeks consistent use. Confirm exact composition with your prescribing clinic.',
        };
      case 'KLOW':
        return {
          'Dosage':    'Per clinic protocol',
          'Half-life': 'Varies by component',
          'Frequency': 'Once daily or as directed',
          'Route':     'Subcutaneous injection',
          'Notes':     'Proprietary metabolic/weight management blend — formulation varies by clinic. May contain HGH Frag 176-191, AOD-9604, 5-Amino-1MQ, and/or GLP-1 analogs. Targets visceral fat reduction and metabolic rate. Confirm exact composition and dosing protocol with your prescribing clinic.',
        };
      case 'Dihexa':
        return {
          'Dosage':    '10–30 mg/day (oral) or lower subQ',
          'Half-life': 'Long (days, exact unknown)',
          'Frequency': 'Once daily or cycling as needed',
          'Route':     'Oral or subcutaneous injection',
          'Notes':     'Extremely potent HGF/c-Met agonist — reported ~10 million times more potent than BDNF in some neurogenesis measures. Stimulates synaptogenesis, neurogenesis, and cognitive function. Used for cognitive decline, neurological recovery, and performance enhancement. Very limited human research — start very low and dose conservatively. Sublingual administration improves absorption. May cause overstimulation at high doses.',
        };
      case 'Glutathione':
        return {
          'Dosage':    'IV: 600–1200 mg/session  |  SubQ: 200–500 mg/day',
          'Half-life': 'Short (rapidly oxidized)',
          'Frequency': 'IV: weekly or as needed  |  SubQ: daily',
          'Route':     'Intravenous or subcutaneous injection',
          'Notes':     'The body\'s master antioxidant — neutralizes free radicals, supports liver detoxification (phase II), and inhibits melanin synthesis for skin brightening. Oral bioavailability is very poor; IV or subQ are significantly more effective. Administer IV slowly to avoid flushing. Stack with Vitamin C (1–2 g) to reduce oxidation and extend activity. Often combined with NAD+ infusions.',
        };
      case 'HGH':
        return {
          'Dosage':    '1–4 IU/day (body comp) / 4–8 IU/day (performance)',
          'Half-life': '~2–3 hours (subQ)',
          'Frequency': 'Once daily (morning) or split twice daily',
          'Route':     'Subcutaneous injection',
          'Notes':     'Gold standard for GH therapy. Start at 1–2 IU/day and titrate up to assess tolerance. Common sides at higher doses: water retention, carpal tunnel, joint aches, elevated fasting glucose. Morning injection mimics the natural GH pulse. For higher protocols, split the dose (AM + pre-bed). Monitor IGF-1 blood levels to dial in dosing. Run cycles of 3–6+ months for body composition benefits.',
        };
      case 'Boldenone':
        return {
          'Dosage':    '300–600 mg/week',
          'Half-life': '~8 days (Cypionate ester)',
          'Frequency': 'Twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'The base compound behind EQ (Equipoise = Boldenone Undecylenate). Boldenone Cypionate offers a shorter half-life (~8 days vs EQ\'s ~14 days), providing a faster kick-in and easier blood level management. Same characteristic effects: mild anabolic, appetite stimulation, increased vascularity, and RBC production. Mild aromatizer. Monitor hematocrit on longer cycles. Less common than EQ but preferred when a faster-acting boldenone ester is desired.',
        };
      case 'HMG':
        return {
          'Dosage':    '75–150 IU, 2–3x weekly',
          'Half-life': 'FSH: ~50 hours  |  LH activity: ~20 hours',
          'Frequency': '2–3x weekly',
          'Route':     'Subcutaneous or intramuscular injection',
          'Notes':     'Contains both FSH and LH activity — provides more complete gonadotropin support than HCG alone (which only mimics LH). FSH component directly stimulates Sertoli cells and spermatogenesis, making HMG essential for restoring sperm production after suppressive cycles. Often used alongside HCG in fertility protocols, or when HCG alone fails to restore spermatogenesis. Important for men on TRT wanting to preserve fertility.',
        };
      case 'NPP':
        return {
          'Dosage':    '100–300 mg/week',
          'Half-life': '~5 days',
          'Frequency': 'Every 3–4 days',
          'Route':     'Intramuscular injection',
          'Notes':     'All the benefits of Deca — joint lubrication, quality lean gains, increased nitrogen retention — with a shorter ester that allows faster blood level adjustment. Less water retention than Deca. Same prolactin risk — have cabergoline on hand. PCT can begin sooner after last pin (~2 weeks) vs Deca. Run with testosterone base.',
        };
      case 'Sustanon':
        return {
          'Dosage':    '250–750 mg/week',
          'Half-life': '~15–18 days (blend average)',
          'Frequency': 'Twice weekly or EOD for stable levels',
          'Route':     'Intramuscular injection',
          'Notes':     'Contains 4 esters: Propionate 30 mg, Phenylpropionate 60 mg, Isocaproate 60 mg, Decanoate 100 mg. The short esters cause an early peak (~24–48 hrs) while longer esters sustain levels. Despite the long blend half-life, EOD or twice-weekly injections are needed for stable blood levels. More injection site PIP than single-ester testosterone. PCT: begin 2–3 weeks after last pin.',
        };
      case 'Tren Hex':
        return {
          'Dosage':    '150–400 mg/week',
          'Half-life': '~14 days',
          'Frequency': 'Twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'The original Parabolan — only trenbolone ester ever approved for human use (France, now discontinued). Longest trenbolone ester. Same potency and side-effect profile as Tren Ace/E: night sweats, insomnia, aggression, cardiovascular strain, tren cough possible. Prolactin management with cabergoline. Longer half-life means sides take longer to resolve if they occur.',
        };
      case 'HCG':
        return {
          'Dosage':    '500 IU 2x/week (on-cycle) / 1000–2500 IU EOD (PCT)',
          'Half-life': '~36 hours',
          'Frequency': 'Twice weekly (on-cycle) or EOD (PCT phase)',
          'Route':     'Subcutaneous or intramuscular injection',
          'Notes':     'Mimics LH — stimulates Leydig cells to maintain testosterone production and prevent testicular atrophy during suppressive cycles. On-cycle: 500 IU 2x/week keeps testes active. PCT: run 1000–2500 IU EOD for 1–2 weeks before beginning SERMs. Stop HCG before starting Nolvadex/Clomid — concurrent use may blunt SERM effectiveness. Requires refrigeration.',
        };
      case 'DHB':
        return {
          'Dosage':    '200–400 mg/week',
          'Half-life': '~8 days',
          'Frequency': 'Twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'Roughly 2x more anabolic and androgenic than testosterone — produces lean, dry, hard gains similar to Primo but more potent. No aromatization. Notorious for severe injection site PIP (pain) — diluting with MCT or sterile oil and injecting slowly reduces discomfort. Hair loss risk in predisposed individuals. Strength gains are significant. Increasing in popularity for contest prep.',
        };
      case 'MENT':
        return {
          'Dosage':    '10–25 mg/day or 50–100 mg/week',
          'Half-life': '~8 hours (acetate)',
          'Frequency': 'Daily (acetate) or twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'Approximately 10x more anabolic than testosterone by weight — extreme caution warranted. Does not bind SHBG, leaving more free hormone active. Strong aromatizer — aggressive AI required. Suppresses natural testosterone even at very low doses. Not for beginners. Originally researched as a male contraceptive. Prolactin management may also be needed.',
        };
      case 'Test Base':
        return {
          'Dosage':    '50–100 mg per use',
          'Half-life': '~2–4 hours',
          'Frequency': 'As needed (pre-workout) or daily',
          'Route':     'Intramuscular injection',
          'Notes':     'Pure testosterone with no ester — peaks within hours and clears rapidly. Primarily used as a pre-workout strength booster (inject 30–60 min before training). Very painful injections due to aqueous or microcrystalline suspension. Not practical as a cycle base due to short duration. Often used by experienced athletes for peaking, contests, or when rapid clearance is needed.',
        };
      case 'Test Undecanoate':
        return {
          'Dosage':    '750–1000 mg per injection (TRT)',
          'Half-life': '~21 days',
          'Frequency': 'Loading doses at week 0 and 6, then every 10–14 weeks',
          'Route':     'Deep intramuscular injection (gluteal)',
          'Notes':     'Ultra-long-acting ester — the longest available. FDA-approved for TRT (Aveed in the US, Nebido in Europe). Requires deep IM injection into the gluteal muscle — must be administered by a healthcare provider due to risk of pulmonary oil microembolism (POME). Not suitable for performance cycling due to inability to rapidly adjust blood levels. Ideal for TRT compliance (infrequent dosing).',
        };
      case 'Test E':
        return {
          'Dosage':    '250–500 mg/week',
          'Half-life': '~4.5 days',
          'Frequency': 'Once or twice weekly (e.g. Mon/Thu)',
          'Route':     'Intramuscular injection',
          'Notes':     'The most common testosterone ester for TRT and cycles. Takes 4–6 weeks to fully saturate. Run AI (Anastrozole 0.5 mg EOD or Aromasin 12.5 mg EOD) if estrogen sides emerge. PCT with Nolvadex/Clomid required after cycle. Typical cycle: 12–16 weeks.',
        };
      case 'Test C':
        return {
          'Dosage':    '250–500 mg/week',
          'Half-life': '~8 days',
          'Frequency': 'Once or twice weekly (e.g. Mon/Thu)',
          'Route':     'Intramuscular injection',
          'Notes':     'Virtually identical to Test E in effect — slightly longer half-life makes once-weekly injections viable. The standard for TRT in the US. Stable blood levels with twice-weekly pinning. AI and PCT protocols same as Test E.',
        };
      case 'Test P':
        return {
          'Dosage':    '50–100 mg/EOD',
          'Half-life': '~2 days',
          'Frequency': 'Every other day',
          'Route':     'Intramuscular injection',
          'Notes':     'Short ester — fastest kick-in of testosterone esters (~2 weeks). Requires EOD injections to maintain stable levels. Preferred for shorter cycles and for those sensitive to estrogen (easier to control). More injection site discomfort than long esters. PCT can begin sooner after last pin (~3–4 days).',
        };
      case 'MK-677':
        return {
          'Dosage':    '10–25 mg/day',
          'Half-life': '~24 hours',
          'Frequency': 'Once daily, before bed',
          'Route':     'Oral',
          'Notes':     'Oral GH secretagogue — mimics ghrelin to stimulate pituitary GH release. Raises both GH and IGF-1 without suppressing natural production. Common sides: water retention, increased appetite, mild lethargy, and elevated fasting glucose. Best taken before bed to align with natural GH pulse. Can be run long-term (months). No PCT needed.',
        };
      case 'Anavar':
        return {
          'Dosage':    '20–80 mg/day (men) / 5–20 mg/day (women)',
          'Half-life': '~9 hours',
          'Frequency': 'Split into 2 doses daily',
          'Route':     'Oral',
          'Notes':     'One of the mildest orals — low androgenicity, mild hepatotoxicity, no aromatization. Ideal for strength and lean mass without significant weight gain. One of the most popular compounds for women due to low virilization risk at low doses. Lipid strain is still present — monitor cholesterol. Typical cycle: 6–8 weeks.',
        };
      case 'Deca':
        return {
          'Dosage':    '200–600 mg/week',
          'Half-life': '~15 days',
          'Frequency': 'Once weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'Known for joint lubrication. Run with testosterone to offset libido suppression. PCT required. Can cause "Deca dick" if run without test.',
        };
      case 'Tren Ace':
        return {
          'Dosage':    '150–400 mg/week',
          'Half-life': '~3 days',
          'Frequency': 'Every other day',
          'Route':     'Intramuscular injection',
          'Notes':     'Very potent — not recommended for beginners. Common sides: night sweats, insomnia, tren cough, aggression. No aromatization but prolactin management may be needed (cabergoline).',
        };
      case 'Tren E':
        return {
          'Dosage':    '150–400 mg/week',
          'Half-life': '~11 days',
          'Frequency': 'Twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'Same effects as Tren Ace but longer half-life makes side effect management harder. Prolactin management recommended (cabergoline).',
        };
      case 'EQ':
        return {
          'Dosage':    '300–600 mg/week',
          'Half-life': '~14 days',
          'Frequency': 'Once or twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'Increases RBC and appetite. Mild aromatization. Needs long cycle (16+ weeks) due to slow kick-in. Can raise hematocrit — monitor blood.',
        };
      case 'Masteron':
        return {
          'Dosage':    '300–600 mg/week',
          'Half-life': 'Prop: ~3 days / Enanthate: ~10 days',
          'Frequency': 'EOD (Prop) or twice weekly (Enanthate)',
          'Route':     'Intramuscular injection',
          'Notes':     'DHT-derivative — no estrogenic activity, mild anti-estrogenic effect. Best used sub-15% body fat for hardening effect. Hair loss risk in predisposed individuals.',
        };
      case 'Primo':
        return {
          'Dosage':    '400–800 mg/week',
          'Half-life': '~10 days',
          'Frequency': 'Twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'One of the safest anabolics — no aromatization, low androgenicity. Expensive and often faked. Ideal for lean mass and cutting phases.',
        };
      case 'Winstrol':
        return {
          'Dosage':    '25–75 mg/day (oral) / 25–50 mg/EOD (injectable)',
          'Half-life': '~9 hours (oral) / ~24 hours (injectable)',
          'Frequency': 'Daily (oral) or EOD (injectable)',
          'Route':     'Oral or intramuscular injection',
          'Notes':     'No water retention — popular for cutting and athletic performance. Hepatotoxic (oral). Can cause joint pain at high doses. Hair loss risk.',
        };
      case 'Dbol':
        return {
          'Dosage':    '20–50 mg/day',
          'Half-life': '~4–6 hours',
          'Frequency': 'Split into 2–3 doses daily',
          'Route':     'Oral',
          'Notes':     'Classic kickstart compound. Significant water retention and aromatization — AI required. Hepatotoxic; limit use to 4–6 weeks. Great for rapid strength and mass gains.',
        };
      case 'Anadrol':
        return {
          'Dosage':    '25–100 mg/day',
          'Half-life': '~8–9 hours',
          'Frequency': 'Once or twice daily',
          'Route':     'Oral',
          'Notes':     'One of the most potent oral mass builders. Highly hepatotoxic — limit to 4–6 weeks. Does not aromatize but still causes water retention (likely via progesterone or other pathways). AI may still be needed.',
        };
      case 'Tbol':
        return {
          'Dosage':    '30–60 mg/day',
          'Half-life': '~16 hours',
          'Frequency': 'Once or twice daily',
          'Route':     'Oral',
          'Notes':     'Clean, dry gains with no estrogenic activity. Milder than Dbol. Popular for strength and lean mass without bloat. Hepatotoxic — limit to 6–8 weeks.',
        };
      case 'Superdrol':
        return {
          'Dosage':    '10–30 mg/day',
          'Half-life': '~8 hours',
          'Frequency': 'Once or twice daily',
          'Route':     'Oral',
          'Notes':     'Extremely potent dry mass builder. Highly hepatotoxic — strict 4-week limit. Requires liver support (TUDCA/NAC). No aromatization. Can cause lethargy and lipid strain.',
        };
      case 'Ostarine':
        return {
          'Dosage':    '10–25 mg/day',
          'Half-life': '~24 hours',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'The mildest and most researched SARM — was in Phase III clinical trials for muscle wasting (Enobosarm). Minimal suppression at 10–15 mg; more suppressive at 25 mg or beyond 12 weeks. Ideal first SARM or for lean mass preservation during a cut. Mini-PCT (Nolvadex 20 mg × 4 weeks) recommended after longer or higher-dose cycles. Well tolerated with a low side-effect profile relative to other SARMs.',
        };
      case 'RAD140':
        return {
          'Dosage':    '5–20 mg/day',
          'Half-life': '~60 hours',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'One of the most potent SARMs — anabolic:androgenic ratio approximately 90:1 vs testosterone\'s 1:1. Significant strength and lean muscle gains. Suppressive at higher doses — a mini-PCT (Nolvadex 4 weeks) is often needed. Hepatotoxicity has been reported — monitor liver enzymes. Research suggests neuroprotective properties. Start at 5–10 mg and assess response. Typical cycle: 8–12 weeks.',
        };
      case 'Enclo':
        return {
          'Dosage':    '12.5–25 mg/day',
          'Half-life': '~10 hours',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'The active trans-isomer of clomiphene — blocks hypothalamic estrogen receptors to drive LH/FSH and restore endogenous testosterone. Unlike Clomid, contains no zuclomiphene (the cis-isomer responsible for visual disturbances and mood sides). Growing use as a non-suppressive TRT alternative that preserves fertility and natural production. Well tolerated.',
        };
      case 'Finasteride':
        return {
          'Dosage':    '0.5–1 mg/day (hair) / 5 mg/day (BPH)',
          'Half-life': '~5–6 hours',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'Blocks 5-alpha reductase enzyme, preventing testosterone-to-DHT conversion. Used to combat steroid-induced hair loss — effective against DHT-derived androgens only (Test, Proviron). Counterproductive if running DHT-derived anabolics (Winstrol, Masteron, Anavar) as it blunts their effect. May reduce libido and sexual function in some users. Post-finasteride syndrome is debated but reported.',
        };
      case 'Cabergoline':
        return {
          'Dosage':    '0.25–0.5 mg, twice weekly',
          'Half-life': '~65 hours',
          'Frequency': 'Twice weekly',
          'Route':     'Oral',
          'Notes':     'Dopamine D2 agonist — suppresses prolactin secretion from the pituitary. Essential for managing high prolactin from 19-nor compounds (Deca, NPP, Tren). Symptoms of elevated prolactin: gyno, low libido, sexual dysfunction, nipple discharge. Long half-life means twice-weekly dosing is sufficient. Take with food to reduce nausea. Gold standard over bromocriptine for tolerability and potency.',
        };
      case 'Tamoxifen':
        return {
          'Dosage':    'PCT: 40/40/20/20 mg/day  |  Gyno: 20–40 mg/day',
          'Half-life': '~5–7 days',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'Selective estrogen receptor modulator (SERM) — blocks estrogen receptors in breast tissue without lowering serum estrogen. First-line for on-cycle gyno and the cornerstone of PCT. Does NOT lower blood estrogen levels (unlike AIs). PCT protocol: 40 mg/day × 2 weeks, then 20 mg/day × 2 weeks. Can combine with Clomid for stronger HPTA restart. Rare: visual disturbances at high doses.',
        };
      case 'Clomid':
        return {
          'Dosage':    'PCT: 50/50/25/25 mg/day  |  TRT alt: 25 mg/day',
          'Half-life': '~5–7 days',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'Blocks hypothalamic/pituitary estrogen receptors — triggers LH and FSH release to restart endogenous testosterone production. Classic PCT compound, often stacked with Nolvadex for a stronger HPTA restart. Sides (vision floaters, mood swings, emotional blunting) are caused by the zuclomiphene isomer — Enclomiphene avoids these. Effective for restoring natural test after suppressive cycles.',
        };
      case 'Aromasin':
        return {
          'Dosage':    '12.5–25 mg/day or EOD',
          'Half-life': '~27 hours',
          'Frequency': 'Once daily or every other day',
          'Route':     'Oral',
          'Notes':     'Suicidal (irreversible) AI — permanently deactivates aromatase enzyme molecules on contact. No estrogen rebound when discontinued, making it preferred when transitioning into PCT. Mildly anabolic due to its steroidal backbone and can slightly raise IGF-1. Crashing estrogen is still possible at high doses — watch for joint pain, low libido, lethargy, and depression. Generally preferred over Arimidex for PCT contexts.',
        };
      case 'Arimidex':
        return {
          'Dosage':    '0.25–1 mg/day or EOD',
          'Half-life': '~48 hours',
          'Frequency': 'Every other day',
          'Route':     'Oral',
          'Notes':     'Competitive (reversible) non-steroidal AI — binds aromatase to block estrogen conversion. Highly effective and titratable. Estrogen rebound is possible upon discontinuation due to reversible binding — not ideal to stop cold in PCT. Risk of crashing estrogen with overuse: joint pain, dry skin, low libido, cognitive fog. Common dosing: 0.5 mg EOD with moderate testosterone cycles, adjusted based on bloodwork.',
        };
      case 'Proviron':
        return {
          'Dosage':    '25–100 mg/day',
          'Half-life': '~12 hours',
          'Frequency': 'Split into 2 doses daily',
          'Route':     'Oral',
          'Notes':     'Oral DHT derivative with unique on-cycle utility — strongly binds SHBG, freeing more testosterone and other steroids to exert their effects. Mild anti-estrogenic action. Improves libido, mood, and sense of well-being. Adds a hardening and dryness effect to physique. Very low hepatotoxicity for an oral. Hair loss risk in predisposed individuals. Not anabolic enough to use alone — always run alongside other compounds.',
        };
      case 'Halotestin':
        return {
          'Dosage':    '5–20 mg/day',
          'Half-life': '~9.5 hours',
          'Frequency': 'Split into 2 doses daily',
          'Route':     'Oral',
          'Notes':     'One of the most androgenic compounds available — used exclusively for explosive strength, aggression, and CNS activation, not mass building. Favored by powerlifters and combat athletes pre-competition. Extremely hepatotoxic — 4-week absolute maximum, TUDCA/NAC mandatory. Significant cardiovascular and lipid strain. No aromatization. Not recommended for beginners — reserve for experienced users with specific strength goals.',
        };
      case 'T3':
        return {
          'Dosage':    '25–100 mcg/day',
          'Half-life': '~2.5 days',
          'Frequency': 'Once or twice daily',
          'Route':     'Oral',
          'Notes':     'Exogenous active thyroid hormone — directly increases basal metabolic rate and fat oxidation. Popular in contest prep for enhanced fat loss. High doses risk significant muscle catabolism — always run alongside anabolics and sufficient protein. Start at 25 mcg and increase by 25 mcg every 1–2 weeks. Must taper down slowly over 2+ weeks — abrupt cessation causes temporary rebound hypothyroidism. Max cycle: 6–8 weeks.',
        };
      case 'Telmisartan':
        return {
          'Dosage':    '20–80 mg/day',
          'Half-life': '~24 hours',
          'Frequency': 'Once daily',
          'Route':     'Oral',
          'Notes':     'Angiotensin II receptor blocker (ARB) — manages steroid-induced hypertension effectively. Uniquely also acts as a PPAR-delta agonist, improving insulin sensitivity, lipid profiles, and mitochondrial biogenesis. Popular in performance circles for dual blood pressure and metabolic benefits. Well tolerated. Consider for any cycle that raises BP significantly (Tren, high-dose Test, orals). Monitor blood pressure regularly on cycle.',
        };
      case 'Clenbuterol':
        return {
          'Dosage':    '20–120 mcg/day',
          'Half-life': '~36–48 hours',
          'Frequency': 'Once daily (morning)',
          'Route':     'Oral',
          'Notes':     'Beta-2 adrenergic agonist — increases thermogenesis and metabolic rate via sympathomimetic stimulation. Common sides: hand tremors, heart palpitations, sweating, insomnia, muscle cramps (taurine depletion — supplement 3–5 g/day). Use 2-weeks-on/2-weeks-off cycling to prevent receptor desensitization. Start at 20 mcg and increase by 20 mcg every 2–3 days to tolerance. Potassium supplementation also recommended. Not meaningfully anabolic in humans.',
        };
      case 'Viagra':
        return {
          'Dosage':    '25–100 mg per use',
          'Half-life': '~4 hours',
          'Frequency': 'As needed, 30–60 min before activity',
          'Route':     'Oral',
          'Notes':     'PDE5 inhibitor — prevents breakdown of cGMP, increasing blood flow and smooth muscle relaxation. Used for erectile dysfunction and sexual performance. Also used off-label for pulmonary arterial hypertension and cardiovascular support during steroid cycles. Onset: 30–60 min, duration ~4–6 hours. Absolutely contraindicated with nitrates (severe hypotension risk). Common sides: flushing, headache, nasal congestion, visual blue tint. 100 mg is the maximum single dose.',
        };
      case 'Cialis':
        return {
          'Dosage':    '5 mg/day (daily) or 10–20 mg as needed',
          'Half-life': '~17.5 hours',
          'Frequency': 'Daily (low dose) or as needed',
          'Route':     'Oral',
          'Notes':     'Long-acting PDE5 inhibitor — half-life of ~17.5 hours allows once-daily low-dose use (5 mg) for continuous effect. As-needed dosing (10–20 mg) lasts up to 36 hours, earning the nickname "the weekend pill." Popular with steroid users for managing cycle-induced blood pressure and supporting cardiovascular function. Also treats BPH. Fewer visual side effects than Sildenafil. Contraindicated with nitrates.',
        };
      case 'Minoxidil':
        return {
          'Dosage':    'Topical: 1 mL 2x daily (2–5%)  |  Oral: 0.25–2.5 mg/day',
          'Half-life': '~4 hours',
          'Frequency': 'Twice daily (topical) or once daily (oral)',
          'Route':     'Topical or oral',
          'Notes':     'Potassium channel opener — extends the anagen (growth) phase of hair follicles and improves scalp microcirculation. Topical (2–5%) is the standard; low-dose oral (0.25–1.25 mg/day) is increasingly popular for greater systemic coverage and convenience. Oral side effects at higher doses: fluid retention, tachycardia, unwanted facial/body hair. Results take 3–6 months — must continue indefinitely, as hair loss resumes within months of stopping.',
        };
      case 'Isotretinoin':
        return {
          'Dosage':    '0.5–1 mg/kg/day (typically 20–80 mg/day)',
          'Half-life': '~10–20 hours',
          'Frequency': 'Once or twice daily with food',
          'Route':     'Oral',
          'Notes':     'Vitamin A (retinoid) derivative — dramatically reduces sebaceous gland size and sebum output. Highly effective for severe, cystic, or steroid-induced acne. Typical course: 4–6 months. Highly teratogenic — mandatory pregnancy prevention (iPLEDGE program in the US). Mandatory blood monitoring: lipids and liver enzymes can be significantly elevated. Common sides: severely dry lips/skin/eyes, photosensitivity, joint pain. Avoid alcohol. Do not donate blood during or 1 month after course.',
        };
      default:
        return {
          'Dosage':    'Varies',
          'Half-life': 'Varies',
          'Frequency': 'Varies',
          'Route':     'Varies',
          'Notes':     'Consult research literature for specific protocols.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(compound.category);
    final icon = _categoryIcon(compound.category);
    final details = _getDetails();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _header(context, color, icon),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description card
                          _descriptionCard(context, color),

                          const SizedBox(height: 20),

                          // Info tiles
                          _sectionLabel(context, "COMPOUND PROFILE"),
                          const SizedBox(height: 12),
                          ...details.entries
                              .where((e) => e.key != 'Notes')
                              .map((e) => _infoTile(context, e.key, e.value, color)),

                          const SizedBox(height: 20),

                          // Notes card
                          if (details.containsKey('Notes'))
                            _notesCard(details['Notes']!, color),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add to Tracker button
            _addButton(context, color),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            context.colors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compound.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (compound.genericName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        compound.genericName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        compound.category,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== DESCRIPTION CARD =====
  Widget _descriptionCard(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              compound.description,
              style: TextStyle(
                  fontSize: 14, height: 1.5, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SECTION LABEL =====
  Widget _sectionLabel(BuildContext context, String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.border, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== INFO TILE =====
  Widget _infoTile(BuildContext context, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ===== NOTES CARD =====
  Widget _notesCard(String notes, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                  fontSize: 13, height: 1.5, color: color.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== ADD BUTTON =====
  Widget _addButton(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.card)),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVialScreen(initialCompound: compound.name),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              "Add Compound",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}