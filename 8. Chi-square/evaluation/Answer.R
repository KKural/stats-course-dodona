context({
  testcase(
    " ",
    {
      testEqual(
        "",
        function(env) as.numeric(env$evaluationResult),
        8.54,  # the correct chi-square value
        comparator = function(generated, expected, ...) {
          # Get the exact student answer for feedback
          student_answer <- tryCatch({
            as.numeric(generated)
          }, error = function(e) {
            return(NA)
          })
          
          # Create observed frequency matrix - consistent with the example
          observed <- matrix(c(
            25, 15,  # Laag opgeleid: geweld, diefstal
            18, 22,  # Midden opgeleid: geweld, diefstal
            12, 28   # Hoog opgeleid: geweld, diefstal
          ), nrow = 3, byrow = TRUE)
          row_sums <- rowSums(observed)
          col_sums <- colSums(observed)
          total <- sum(observed)
          
          # Calculate expected values
          expected_values <- matrix(NA, nrow=3, ncol=2)
          chi_square_components <- matrix(NA, nrow=3, ncol=2)
          
          for(i in 1:3) {
            for(j in 1:2) {
              expected_values[i,j] <- row_sums[i] * col_sums[j] / total
              chi_square_components[i,j] <- ((observed[i,j] - expected_values[i,j])^2) / expected_values[i,j]
            }
          }
          
          chi_square_value <- sum(chi_square_components)
          chi_square_rounded <- round(chi_square_value, 2)
          
          # Determine if answer is correct
          is_correct <- !is.na(student_answer) && abs(student_answer - chi_square_rounded) < 0.1
            if (is_correct) {
            # Detailed feedback for correct answer
            get_reporter()$add_message(
              paste0("✅ Juist! De chi-kwadraat waarde is inderdaad ", chi_square_rounded, ".\n\n",
                    "**Stapsgewijze berekening:**\n\n",
                    "1. **Berekening van verwachte waarden:**\n",
                    "   - E(Laag, Geweld) = (", row_sums[1], " × ", col_sums[1], ") / ", total, " = ", round(expected_values[1,1], 2), "\n",
                    "   - E(Midden, Geweld) = (", row_sums[2], " × ", col_sums[1], ") / ", total, " = ", round(expected_values[2,1], 2), "\n",
                    "   - E(Hoog, Geweld) = (", row_sums[3], " × ", col_sums[1], ") / ", total, " = ", round(expected_values[3,1], 2), "\n",
                    "   - E(Laag, Diefstal) = (", row_sums[1], " × ", col_sums[2], ") / ", total, " = ", round(expected_values[1,2], 2), "\n",
                    "   - E(Midden, Diefstal) = (", row_sums[2], " × ", col_sums[2], ") / ", total, " = ", round(expected_values[2,2], 2), "\n",
                    "   - E(Hoog, Diefstal) = (", row_sums[3], " × ", col_sums[2], ") / ", total, " = ", round(expected_values[3,2], 2), "\n\n",
                    "2. **Berekening van chi-kwadraat componenten:** (O-E)²/E\n",
                    "   - (25-", round(expected_values[1,1], 2), ")²/", round(expected_values[1,1], 2), " = ", round(chi_square_components[1,1], 2), "\n",
                    "   - (18-", round(expected_values[2,1], 2), ")²/", round(expected_values[2,1], 2), " = ", round(chi_square_components[2,1], 2), "\n",
                    "   - (12-", round(expected_values[3,1], 2), ")²/", round(expected_values[3,1], 2), " = ", round(chi_square_components[3,1], 2), "\n",
                    "   - (15-", round(expected_values[1,2], 2), ")²/", round(expected_values[1,2], 2), " = ", round(chi_square_components[1,2], 2), "\n",
                    "   - (22-", round(expected_values[2,2], 2), ")²/", round(expected_values[2,2], 2), " = ", round(chi_square_components[2,2], 2), "\n",
                    "   - (28-", round(expected_values[3,2], 2), ")²/", round(expected_values[3,2], 2), " = ", round(chi_square_components[3,2], 2), "\n\n",
                    "3. **Chi-kwadraat waarde:** Som van alle componenten = ", chi_square_rounded, "\n\n",
                    "4. **Vrijheidsgraden:** (rijen-1) × (kolommen-1) = 2 × 1 = 2\n\n",
                    "5. **Conclusie:** Bij α = 0.05 en df = 2 is de kritieke waarde 5.99. Omdat ", chi_square_rounded, 
                    " > 5.99, verwerpen we de nulhypothese dat er geen verband is tussen opleidingsniveau en type misdrijf.\n\n",                    "**R code om dit te berekenen:**\n\n",
                    "```\n",
                    "# Maak de geobserveerde frequentietabel\n",
                    "observed <- matrix(c(\n",
                    "  25, 15,  # Laag opgeleid: geweld, diefstal\n",
                    "  18, 22,  # Midden opgeleid: geweld, diefstal\n",
                    "  12, 28   # Hoog opgeleid: geweld, diefstal\n",
                    "), nrow = 3, byrow = TRUE)\n",
                    "\n",
                    "# Voer chi-kwadraat test uit\n",
                    "chisq_result <- chisq.test(observed)\n",
                    "\n",
                    "# Rond af op 2 decimalen\n",
                    "round(chisq_result$statistic, 2)\n",
                    "# X-squared\n",
                    "#     ", chi_square_rounded, "\n",
                    "```"
              ), type = "markdown"
            )          } else {
            # Feedback for incorrect answers
            if (is.na(student_answer)) {
              get_reporter()$add_message("❌ Fout. Je hebt geen geldige numerieke waarde ingevoerd. Voer de chi-kwadraat waarde in als een getal, bijvoorbeeld: 8.54", type = "markdown")
            } else if (abs(student_answer - 5.99) < 0.1) {              get_reporter()$add_message(
                paste0("❌ Fout. Je lijkt de kritieke waarde van de chi-kwadraat verdeling (5.99 bij α = 0.05, df = 2) te hebben gegeven in plaats van de berekende toetsstatistiek.\n\n",
                       "Je moet de chi-kwadraat toetsstatistiek berekenen met de formule:\n\n",
                       "χ² = Σ[(Oᵢⱼ - Eᵢⱼ)² / Eᵢⱼ]\n\n",
                       "In R kun je dit doen met:\n\n```\n",
                       "chisq.test(observed)$statistic\n",
                       "```"), type = "markdown")} else if (abs(student_answer - 2) < 0.1) {
              get_reporter()$add_message("❌ Fout. Je hebt het aantal vrijheidsgraden (df = 2) ingevuld in plaats van de chi-kwadraat waarde.", type = "markdown")} else if (student_answer < 0) {
              get_reporter()$add_message("❌ Fout. De chi-kwadraat waarde kan niet negatief zijn.", type = "markdown")} else if (abs(student_answer - 11.89) < 0.1) {              get_reporter()$add_message(
                paste0("❌ Fout. Je antwoord 11.89 is niet correct. De juiste chi-kwadraat waarde is ", chi_square_rounded, ".\n\n",
                       "Je hebt mogelijk een berekeningsfout gemaakt. Controleer of je de verwachte frequenties correct hebt berekend met de formule E = (rijtotaal × kolomtotaal) / totaal."), type = "markdown")            } else {
              get_reporter()$add_message(
                paste0("❌ Fout. Je antwoord ", student_answer, " is niet correct. De juiste chi-kwadraat waarde is ", chi_square_rounded, ".\n\n",
                       "**Herinner je de formule voor chi-kwadraat:**\n\nχ² = Σ [(Oᵢⱼ - Eᵢⱼ)² / Eᵢⱼ]\n\n",
                       "**Tips voor de berekening:**\n\n",
                       "1. Bereken eerst de verwachte frequenties voor elke cel: Eᵢⱼ = (rijtotaal × kolomtotaal) / totaal\n",
                       "2. Bereken voor elke cel: (Oᵢⱼ - Eᵢⱼ)² / Eᵢⱼ\n",
                       "3. Tel alle waarden uit stap 2 bij elkaar op om χ² te krijgen\n\n",
                       "**In R kun je dit berekenen met:**\n\n```\n",
                       "observed <- matrix(c(\n",
                       "  25, 15,  # Laag opgeleid: geweld, diefstal\n",
                       "  18, 22,  # Midden opgeleid: geweld, diefstal\n",
                       "  12, 28   # Hoog opgeleid: geweld, diefstal\n",
                       "), nrow = 3, byrow = TRUE)\n",
                       "chisq.test(observed)$statistic\n",
                       "```"), type = "markdown")}
          }
          
          # Following the pattern from multiple-choice questions
          return(abs(student_answer - expected) < 0.1)
        }
      )
    }
  )
})
