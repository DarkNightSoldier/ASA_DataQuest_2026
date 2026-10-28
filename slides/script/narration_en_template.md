<!--
  PLANTILLA DEL GUION FINAL (agente script-narration, 2026-10-25; v4 corrector-final 2026-10-25: hallazgos QA-ethics/slides/viz; v5 cierre-rc2 2026-10-27: jurado final + nombres de técnicas) — fuente única de la voz.
  · "## <diapositiva> · <título>" y "### <data-step>" en el mismo orden que slides/index.html.
  · Una frase por línea "> …" (≤ 18 palabras); " | " parte la frase en bloques de subtítulo (≤ 90 caracteres).
  · Marcadores entre llaves (clave, clave.say, clave.voice, ^clave) se resuelven con fill_numbers.py (solo verified: true).
  · Constantes de diseño (237, 2023, 2000, 2050, cuatro hijos, cinco → tres, 30 → 40, veinte puestos,
    95 percent) se escriben tal cual (storyboard v2.1, nota de cabecera).
  · Regenerar: python slides/script/build_narration.py
-->

## cover · One number can't tell 8 billion stories

### cover.b1
> {^world_pop_2023_bn.say} people.

### cover.b2
> In 2023, {n_below_replacement_2023} countries and areas | had fertility below the level that replaces each generation.

### cover.b3
> Yet {n_below_repl_growing_2023} are still growing.
> {n_below_repl_natural_growth_2023} have more births than deaths; | {n_grow_only_migration_2023} grow only because more people arrive than leave.

### cover.b4
> One number can't explain that.

### cover.b5
> We are Team {team_name}.

## s1 · Question 1: which lever moves each country's population?

### s1.b0
> Three questions.
> One: how do births, deaths and migration relate, | by region, country and income?
> Two: does one indicator tell the whole story, or only several together?
> Three: do countries share one road at different speeds, | and what should the UN watch?

### s1.b1
> Population change is bookkeeping: | births minus deaths, plus net migration.

### s1.b2
> In today's high-income countries, net migration accounted for | about {share_mig_high_2000_2023.say} of the growth since 2000.
> Elsewhere, growth came almost entirely from births exceeding deaths.

### s1.b3
> Blue: more births than deaths, and growing,

### s1.b3b
> including {n_momentum_countries} below replacement that grow with no net arrivals.

### s1.b4a
> Light blue: deaths exceed births, but arrivals keep it growing.

### s1.b4b
> Orange: deaths exceed births, and it shrinks.

### s1.b4c
> Purple: births exceed deaths, but net departures make it shrink.

### s1.b5a
> Migration is also the least certain lever.

### s1.b5b
> For the Emirates in 2050, the UN's 95 percent range | is {pop_are_2050_pi95_low.say} to {pop_are_2050_pi95_high.say} million.

## s2 · Question 1 (cont.): same road, different speed

### s2.b0

### s2.b1
> Set each country's clock to when its fertility fell below four children, | and the curves line up.
> The road is shared; the speed is not.
> China went from five to three children in {dur53_chn} years; | Egypt took {dur53_egy}.

### s2.b2
> Survival analysis: child deaths started falling first | in {n_mort_first_onset} of {n_onset} high-fertility countries.
> The gap was typically at least {lag_onset_lower_bound} years.

### s2.b3
> A within-country panel regression | finds this link smaller than comparing countries suggests.
> A sequence in time, not proof of cause.

### s2.b4
> Question one, answered: child deaths fell first and births followed, | at each country's pace; latest in low-income countries.
> The link is clearest in sub-Saharan Africa.
> Migration moves on its own, alike among neighbours only in the Gulf, | and weighs most in high-income countries.

## s3 · Question 2: does one indicator tell the whole story?

### s3.b0

### s3.b1
> Question two.
> Fertility alone captures the slow story: | about {r2_tfr_medage.say} of the differences in how old populations are.
> Only part of today's growth, and almost none of migration.

### s3.b2
> Fertility alone finds only {knn_tfr.say} | of each country's closest look-alikes.

### s3.b3
> Principal component analysis: countries differ in two separate ways.
> Fertility tracks the first, the transition to fewer births and deaths, | but misses migration.

### s3.b4
> Blend indicators into one score: | the weights can shift {share_rank_mc20.say} by more than twenty places.
> Question two, answered: no.
> The Emirates and Belarus share the same fertility; | one grows almost {twin_growth_are.say} percent a year, the other shrinks.
> The story emerges only when transition and migration are read together.

## s4 · Question 3: one road, four groups — and what to watch on each

### s4.b0

### s4.b1
> Question three.
> K-means groups countries' seventy-year paths into three stretches of one road, | plus a migration-led group, mostly Gulf states.
> Early movers are projected to grow only through migration, or shrink.
> Fast movers, {cluster_examples_fast.voice}, | are projected to age from 30 to 40 in {yrs_medage30_40_recent.say} years.
> About as fast as Early movers did, or faster.
> Recent movers have the highest child mortality today.

### s4.b2
> Countries grew closer in life expectancy, but further apart in age.

### s4.b3
> Question three, answered: mostly one road, at different speeds.
> For the UN: watch child survival where it is off pace for the 2030 goal.
> Watch ageing where fertility is low but populations still grow.
> Watch migration data where growth depends on arrivals.

### s4.b4
> Following ASA guidelines, projections are scenarios; | hypotheses were fixed before the final run.
> These are patterns, not causes; | every number and our AI use are documented in our notebook.

### s4.b5
> One number can't tell eight billion stories.
> But births, deaths and migration, read together region by region, | can tell the UN where to look next.

## refs · References

### refs
