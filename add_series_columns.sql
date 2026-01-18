-- =====================================================
-- MIGRATION: Ajout colonnes Séries / Charges / Répétitions
-- À exécuter dans la console SQL de Supabase
-- =====================================================

-- 1. Ajouter les colonnes de configuration dans la table 'rooms'
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS notebook_visible_series BOOLEAN DEFAULT false;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS notebook_series_count INTEGER DEFAULT 4;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS notebook_visible_charges BOOLEAN DEFAULT false;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS notebook_visible_reps BOOLEAN DEFAULT false;

-- 2. Ajouter les colonnes de données dans la table 'notebook_entries'
ALTER TABLE notebook_entries ADD COLUMN IF NOT EXISTS series_number INTEGER DEFAULT 1;
ALTER TABLE notebook_entries ADD COLUMN IF NOT EXISTS charge TEXT;
ALTER TABLE notebook_entries ADD COLUMN IF NOT EXISTS repetitions TEXT;

-- 3. Supprimer l'ancienne contrainte d'unicité si elle existe
ALTER TABLE notebook_entries DROP CONSTRAINT IF EXISTS notebook_entries_student_id_workshop_id_key;

-- 4. Ajouter la nouvelle contrainte d'unicité incluant series_number
-- (Si cette commande échoue car des doublons existent, voir la section "Nettoyage" ci-dessous)
ALTER TABLE notebook_entries ADD CONSTRAINT notebook_entries_unique 
    UNIQUE (student_id, workshop_id, series_number);

-- =====================================================
-- OPTIONNEL: Nettoyage des doublons (si l'étape 4 échoue)
-- Décommentez et exécutez si nécessaire
-- =====================================================
-- DELETE FROM notebook_entries a USING notebook_entries b
-- WHERE a.id < b.id AND a.student_id = b.student_id AND a.workshop_id = b.workshop_id AND a.series_number = b.series_number;
