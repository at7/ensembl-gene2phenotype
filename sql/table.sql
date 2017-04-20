CREATE TABLE attrib (
  attrib_id int(11) unsigned NOT NULL,
  attrib_type_id smallint(5) unsigned NOT NULL,
  value text NOT NULL,
  PRIMARY KEY (attrib_id),
  UNIQUE KEY attrib_type_idx (attrib_type_id, value(80))
);

CREATE TABLE attrib_type (
  attrib_type_id smallint(5)  unsigned NOT NULL AUTO_INCREMENT,
  code varchar(20) NOT NULL DEFAULT '',
  name varchar(255) NOT NULL DEFAULT '',
  description text, 
  PRIMARY KEY (attrib_type_id),
  UNIQUE KEY code_idx (code)
);

CREATE TABLE disease (
  disease_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  name varchar(255) DEFAULT NULL,
  mim int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (disease_id),
  KEY name_idx (name)
);

CREATE TABLE disease_name_synonym (
  disease_id int(10) unsigned NOT NULL,
  name varchar(255) NOT NULL,
  UNIQUE KEY name (disease_id,name),
  KEY disease_idx (disease_id)
);

CREATE TABLE ensembl_variation (
  ensembl_variation_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_id int(10) unsigned NOT NULL,
  seq_region varchar(128) DEFAULT NULL,
  seq_region_start int(11) NOT NULL,
  seq_region_end int(11) NOT NULL,
  seq_region_strand tinyint(4) NOT NULL,
  name varchar(255) DEFAULT NULL,
  source varchar(24) NOT NULL,
  allele_string varchar(50000) DEFAULT NULL,
  consequence varchar(128) DEFAULT NULL,
  feature_stable_id varchar(128) DEFAULT NULL,
  amino_acid_string varchar(255) DEFAULT NULL,
  polyphen_prediction varchar(128) DEFAULT NULL,
  sift_prediction varchar(128) DEFAULT NULL,
  PRIMARY KEY (ensembl_variation_id),
  KEY genomic_feature_idx (genomic_feature_id)
);

CREATE TABLE genomic_feature (
  genomic_feature_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  gene_symbol varchar(128) DEFAULT NULL,
  hgnc_id int(10) unsigned DEFAULT NULL,
  mim int(10) unsigned DEFAULT NULL,
  ensembl_stable_id varchar(128) DEFAULT NULL,
  seq_region_id int(10) unsigned DEFAULT NULL,
  seq_region_start int(10) unsigned DEFAULT NULL,
  seq_region_end int(10) unsigned DEFAULT NULL,
  seq_region_strand tinyint(2) DEFAULT NULL,
  PRIMARY KEY (genomic_feature_id),
  KEY gene_symbol_idx (gene_symbol),
  KEY mim_idx (mim),
  KEY ensembl_stable_id_idx (ensembl_stable_id)
);

CREATE TABLE genomic_feature_disease (
  genomic_feature_disease_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_id int(10) unsigned NOT NULL,
  disease_id int(10) unsigned NOT NULL,
  DDD_category_attrib set('31', '32', '33', '34', '35') DEFAULT NULL,
  is_visible tinyint(1) unsigned NOT NULL DEFAULT '1',
  panel_attrib tinyint(1) DEFAULT NULL,
  PRIMARY KEY (genomic_feature_disease_id),
  UNIQUE KEY genomic_feature_disease (genomic_feature_id, disease_id, panel_attrib),
  KEY genomic_feature_idx (genomic_feature_id),
  KEY disease_idx (disease_id)
);

CREATE TABLE genomic_feature_disease_deleted (
  genomic_feature_disease_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_id int(10) unsigned NOT NULL,
  disease_id int(10) unsigned NOT NULL,
  DDD_category_attrib set('31', '32', '33', '34', '35') DEFAULT NULL,
  is_visible tinyint(1) unsigned NOT NULL DEFAULT '1',
  panel_attrib tinyint(1) DEFAULT NULL,
  deleted timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  deleted_by_user_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_id),
  KEY genomic_feature_idx (genomic_feature_id),
  KEY disease_idx (disease_id)
);

CREATE TABLE genomic_feature_disease_action (
  genomic_feature_disease_action_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  allelic_requirement_attrib set('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20') DEFAULT NULL,
  mutation_consequence_attrib set('21', '22', '23', '24', '25', '26', '27', '28', '29', '30') DEFAULT NULL,
  PRIMARY KEY (genomic_feature_disease_action_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_action_deleted (
  genomic_feature_disease_action_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  allelic_requirement_attrib set('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20') DEFAULT NULL,
  mutation_consequence_attrib set('21', '22', '23', '24', '25', '26', '27', '28', '29', '30') DEFAULT NULL,
  PRIMARY KEY (genomic_feature_disease_action_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);


CREATE TABLE genomic_feature_disease_action_log (
  genomic_feature_disease_action_log_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_action_id int(10) unsigned NOT NULL,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  allelic_requirement_attrib set('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20') DEFAULT NULL,
  mutation_consequence_attrib set('21', '22', '23', '24', '25', '26', '27', '28', '29', '30') DEFAULT NULL,
  created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id int(10) unsigned NOT NULL, 
  action varchar(128) NOT NULL,
  PRIMARY KEY (genomic_feature_disease_action_log_id),
  KEY genomic_feature_disease_action_idx (genomic_feature_disease_action_id)
);

CREATE TABLE genomic_feature_disease_log (
  genomic_feature_disease_log_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  genomic_feature_id int(10) unsigned NOT NULL,
  disease_id int(10) unsigned NOT NULL,
  DDD_category_attrib set('31', '32', '33', '34', '35') DEFAULT NULL,
  is_visible tinyint(1) unsigned NOT NULL DEFAULT '1',
  panel_attrib tinyint(1) DEFAULT NULL,
  created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id int(10) unsigned NOT NULL,
  action varchar(128) NOT NULL,
  PRIMARY KEY (genomic_feature_disease_log_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_organ (
  genomic_feature_disease_organ_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  organ_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_organ_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_organ_deleted (
  genomic_feature_disease_organ_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  organ_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_organ_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_phenotype (
  genomic_feature_disease_phenotype_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  phenotype_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_phenotype_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_phenotype_deleted (
  genomic_feature_disease_phenotype_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  phenotype_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_phenotype_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_publication (
  genomic_feature_disease_publication_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  publication_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_publication_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_disease_publication_deleted (
  genomic_feature_disease_publication_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_id int(10) unsigned NOT NULL,
  publication_id int(10) unsigned NOT NULL,
  PRIMARY KEY (genomic_feature_disease_publication_id),
  KEY genomic_feature_disease_idx (genomic_feature_disease_id)
);

CREATE TABLE genomic_feature_synonym (
  genomic_feature_id int(10) unsigned NOT NULL,
  name varchar(255) NOT NULL,
  UNIQUE KEY name (genomic_feature_id, name),
  KEY genomic_feature_idx (genomic_feature_id)
);

CREATE TABLE GFD_phenotype_comment (
  GFD_phenotype_comment_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_phenotype_id int(10) unsigned NOT NULL,
  comment_text text DEFAULT NULL,
  created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id int(10) unsigned NOT NULL,
  PRIMARY KEY (GFD_phenotype_comment_id),
  KEY GFD_phenotype_idx (genomic_feature_disease_phenotype_id)
);

CREATE TABLE GFD_phenotype_comment_deleted (
  GFD_phenotype_comment_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_phenotype_id int(10) unsigned NOT NULL,
  comment_text text DEFAULT NULL,
  created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id int(10) unsigned NOT NULL,
  deleted timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  deleted_by_user_id int(10) unsigned NOT NULL,
  PRIMARY KEY (GFD_phenotype_comment_id),
  KEY GFD_phenotype_idx (genomic_feature_disease_phenotype_id)
);

CREATE TABLE GFD_publication_comment (
  GFD_publication_comment_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_publication_id int(10) unsigned NOT NULL,
  comment_text text DEFAULT NULL,
  created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id int(10) unsigned NOT NULL, 
  PRIMARY KEY (GFD_publication_comment_id),
  KEY GFD_publication_idx (genomic_feature_disease_publication_id)
);

CREATE TABLE GFD_publication_comment_deleted (
  GFD_publication_comment_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_disease_publication_id int(10) unsigned NOT NULL,
  comment_text text DEFAULT NULL,
  created timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id int(10) unsigned NOT NULL, 
  deleted timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  deleted_by_user_id int(10) unsigned NOT NULL, 
  PRIMARY KEY (GFD_publication_comment_id),
  KEY GFD_publication_idx (genomic_feature_disease_publication_id)
);

CREATE TABLE organ (
  organ_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  PRIMARY KEY (organ_id)
);

CREATE TABLE panel (
  panel_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  is_visible tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (panel_id)
);

CREATE TABLE organ_panel (
  organ_id int(10) unsigned NOT NULL,
  panel_id int(10) unsigned NOT NULL,
  PRIMARY KEY (organ_id, panel_id),
  KEY organ_panel_idx (organ_id, panel_id)
);

CREATE TABLE phenotype (
  phenotype_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  stable_id varchar(255) DEFAULT NULL,
  name varchar(255) DEFAULT NULL,
  description varchar(255) DEFAULT NULL,
  PRIMARY KEY (phenotype_id),
  UNIQUE KEY desc_idx (description),
  KEY name_idx (name),
  KEY stable_idx (stable_id)
);

CREATE TABLE publication (
  publication_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  pmid int(10) DEFAULT NULL,
  title text DEFAULT NULL,
  source varchar(255) DEFAULT NULL,
  PRIMARY KEY (publication_id),
  KEY pmid_idx (pmid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE search (
  search_term varchar(255) NOT NULL,
  PRIMARY KEY (search_term)
);

CREATE TABLE user (
  user_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  username varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  panel_attrib set('36','37','38','39','40','41','42','43') DEFAULT NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY user_idx (username),
  UNIQUE KEY email_idx (email)
);

CREATE TABLE variation (
  variation_id int(10) unsigned NOT NULL AUTO_INCREMENT,
  genomic_feature_id int(10) unsigned NOT NULL,
  disease_id int(10) unsigned DEFAULT NULL,
  publication_id int(10) unsigned DEFAULT NULL,
  mutation varchar(255) DEFAULT NULL,
  consequence varchar(255) DEFAULT NULL,
  PRIMARY KEY (variation_id),
  KEY disease_idx (disease_id),
  KEY genomic_feature_idx (genomic_feature_id)
);

CREATE TABLE variation_synonym (
  variation_id int(10) unsigned NOT NULL,
  name varchar(128) NOT NULL,
  source varchar(128) NOT NULL,
  UNIQUE KEY name (variation_id,name),
  KEY variation_id (variation_id),
  KEY name_idx (name)
);

