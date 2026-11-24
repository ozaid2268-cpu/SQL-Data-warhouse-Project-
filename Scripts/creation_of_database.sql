/* ============================================================
   Database & Schema Setup — Datawarehousezyyad
   ------------------------------------------------------------
   1. Creates the main data warehouse database
      (Datawarehousezyyad) used across the whole ETL project.
   2. Implements the medallion architecture with three schemas:
      bronze (raw) → silver (cleaned) → gold (business/curated).
   3. Must be run ONCE before any other script — all tables,
      procs, and loads depend on these schemas existing.
   4. Safe to run only on a fresh environment; re-running will
      error (DB/schemas already exist) — not idempotent.
   5. RUN ORDER: this file → bronze DDL → bronze loader →
      silver DDL → silver loader → gold (if applicable).
   ============================================================ */
USE master
-- CREATION OF DATABASE
CREATE DATABASE Datawarehousezyyad
USE Datawarehousezyyad
-- CREATION OF SCHEMAS
CREATE SCHEMA bronze
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
