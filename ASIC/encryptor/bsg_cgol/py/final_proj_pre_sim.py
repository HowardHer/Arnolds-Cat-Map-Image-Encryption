
import yaml # Not installed by default
import cgol
import os
import shutil
import os.path as osp
import numpy as np # Not installed by default
from argparse import ArgumentParser
from tqdm import tqdm # Not installed by default
from math import ceil, log2
from PIL import Image

# Default values:
trace_data_width = 64 # Data traces should be this many bits wide
output_dir = 'out' # GIFs are written here
default_trace_fout = 'v/bsg_trace_master_0.tr' # Default output file

# PARAMS to UPDATE
work_dir_path = '/homes/wuc29/ee526/Arnolds-Cat-Map-Image-Encryption'
py_dir_path = osp.join(work_dir_path, 'ASIC/encryptor/bsg_cgol/py')

def get_bmp_zero_idxs(img_name):
  save_dir = osp.join(py_dir_path, 'debug')
  
  if not osp.exists(save_dir):
    os.mkdir(save_dir)
  
  img_path = osp.join(work_dir_path, ('photos/' + img_name))
  img_name = img_path.split('/')[-1].split('.')[0]
  # print(img_path, img_name)

  img = Image.open(img_path).resize((30, 30))
  ary = np.array(img)

  # Split the three channels
  if len(ary.shape) == 3:
    r,g,b = np.split(ary,3,axis=2)
    r=r.reshape(-1)
    g=r.reshape(-1)
    b=r.reshape(-1)

    # Standard RGB to grayscale 
    bitmap = list(map(lambda x: 0.299 * x[0] + 0.587 * x[1] + 0.114 * x[2], zip(r,g,b)))
    bitmap = np.array(bitmap).reshape([ary.shape[0], ary.shape[1]])

  else:
    bitmap = ary
  
  # switch s, y order
  bmp_z_idx = np.argwhere(bitmap < 200)
  bmp_z_idx = np.roll(bmp_z_idx, 1, axis=1)

  # Save as img
  im = Image.fromarray(bitmap.astype(np.uint8))
  im.save(osp.join(save_dir, (img_name + '.bmp')))
  
  img.save(osp.join(save_dir, (img_name + '_resized.bmp')))
  
  return bmp_z_idx.tolist()

def send_game_req(fout, board:np.ndarray, length, width, max_len):
  '''
  Given a board and a game length, write this to the trace file so the
  data is sent to the DUT.
  '''
  game_len_formatter = f'{{:0{ ceil(log2(max_len+1)) }b}}'
  game_len_bin = game_len_formatter.format(length)
  fout.write(f'### sending board config (game length {length}) ###\n')
  # Write traces to send data
  board_in = board.copy()
  board_in = board_in.reshape((width**2, 1))
  board_in = board_in.squeeze()
  board_in = np.pad(board_in, (0, trace_data_width), 'constant', constant_values=0) # Pad with 0s
  wr_idx = 0
  while wr_idx < width**2:
    if wr_idx==0:
      data = np.flip(board_in[0:(trace_data_width-len(game_len_bin))])
      wr_idx+=(trace_data_width-len(game_len_bin))
      fout.write(f'0001____0_00000000000_{"".join([str(x) for x in data])}_{game_len_bin}\n')
    else:
      data = np.flip(board_in[wr_idx:wr_idx+trace_data_width])
      wr_idx+=trace_data_width
      fout.write(f'0001____0_00000000000_{"".join([str(x) for x in data])}\n')
  fout.write('\n')
  return board

def send_game_check(fout, board:np.ndarray, width):
  '''
  Given a board, write the output expected trace to the trace file.
  '''
  fout.write(f'### Checking board output ###\n')
  board = board.reshape((width**2, 1))
  board = board.squeeze()
  board = np.pad(board, (0, trace_data_width), 'constant', constant_values=0) # Pad with 0s
  wr_idx = 0
  while wr_idx < width**2:
    data = np.flip(board[wr_idx:wr_idx+trace_data_width])
    wr_idx+=trace_data_width
    fout.write(f'0010____0_00000000000_{"".join([str(x) for x in data])}\n')
  fout.write('\n')

def add_image_to_list(list, board, disp):
  # Add a the next image to a list of images
  list.append(cgol.board_to_img2(board, disp['pixel_size'],
                                        a=disp['alive_color'],
                                        d=disp['dead_color']))
  
def add_images_to_list(list, boards, disp):
  for board in boards:
    # Add a the next image to a list of images
    list.append(cgol.board_to_img2(board, disp['pixel_size'],
                                          a=disp['alive_color'],
                                          d=disp['dead_color']))

def main():
  parser = ArgumentParser()
  parser.add_argument('-cfg', required=True, 
                      help='The input config file (in yaml format)')
  parser.add_argument('-out', required=False, default=default_trace_fout, 
                      help=f'Output trace file, defaults to "{default_trace_fout}"')
  args = parser.parse_args()
  
  # MOD
  img_name = 'bigbf.png' #num2.png
  
  print(f'Clearing any previous output in "{output_dir}"...')
  # Create output directory for testbench .data files
  try: shutil.rmtree(output_dir)
  except(FileNotFoundError): pass
  os.mkdir(output_dir)
  
  cfg = yaml.safe_load(open(args.cfg, 'r'))
  width = cfg["board"]["width"]
  max_len = cfg["board"]["max_length"]
  cgol_iterations = 0
  cgol_elapsed_time = 0
  with open(args.out, 'w') as fout:

    # Write trace header
    fout.write('')
    fout.write(f'# This trace file was generated by "final_project_pre_sim.py" with the config file "{args.cfg}", do not directly modify!\n')
    fout.write('\n')
    fout.write(f'# Board size: {width}x{width}, max game length: {cfg["board"]["max_length"]}\n')
    fout.write(f'# Beginning trace ROM with {len(cfg["games"])} games:\n')
    fout.write('\n')

    # Write the config for every game...
    for (idx, game) in enumerate(cfg['games']):
      assert game['length'] <= max_len, 'Max game lenght exceded!'
      fout.write(f'########## Game {idx+1} ##########\n')
      # Generate the initial board
      board = np.zeros((width, width), dtype=np.uint8)
      
      ## MOD: 
      alive_list = get_bmp_zero_idxs(img_name)
      
      ###
      if game['origin'] == 'center':
        for ii, p in enumerate(alive_list): alive_list[ii] = [p[0]+(width//2), p[1]+(width//2)]
      for pt in alive_list: board[pt[0]][pt[1]] = 1
      board = board.transpose()

      # expected_fout = f'game_{idx+1}_{width}x{width}_{game["length"]}.gif'
      fname = img_name.split('.')[0]
      expected_fout = f'{fname}.gif'

      # MOD
      # Generate the trace for this game: only check the last frame
      if game["checks"] == "key":
        send_game_req(fout, board, game['length'], width, max_len) # Send initial data
        print(f'Generating expected results for KEY version ...')
        
        # Simulate Game of Life
        encrypt_imgs = []   # Storing each frame of Encryption
        # decrypt_imgs = []
        with tqdm(range(game['length']), disable=False) as tq:
          # Perform Encryption, saving each frame into gif
          add_image_to_list(encrypt_imgs, board, cfg["display"])  # Add initial frame to gif
          for i in tq:
            board = cgol.ArnoldCatTransform(board)
            add_image_to_list(encrypt_imgs, board, cfg["display"])
          
          # # Perform Decryption, saving each frame into gif
          # add_image_to_list(decrypt_imgs, board, cfg["display"])  # Add initial frame to gif
          # for i in tq:
          #   board = cgol.ArnoldCatDecryption(board, 1)
          #   add_image_to_list(decrypt_imgs, board, cfg["display"])

          # Record stats
          print(tq.format_dict)
          cgol_iterations += tq.format_dict['total']
          cgol_elapsed_time += tq.format_dict['elapsed']
        
        # Save game as a GIF
        cgol.save_gif(encrypt_imgs, os.path.join(output_dir, 'encrypting.gif'), frame_dur=cfg['display']['frame_dur_ms'])
        # cgol.save_gif(decrypt_imgs, os.path.join(output_dir, 'decrypting.gif'), frame_dur=cfg['display']['frame_dur_ms'])
        send_game_check(fout, board, width) # Send output check


      # Generate the trace for this game: only check the last frame
      elif game["checks"] == "last":
        send_game_req(fout, board, game['length'], width, max_len) # Send initial data
        print(f'Generating expected result "{expected_fout}" ...')
        images = []
        # Simulate Game of Life
        with tqdm(range(game['length']), disable=False) as tq:
          for i in tq:
            add_image_to_list(images, board, cfg["display"])

            # board = cgol.cgol_iter3(board)
            board, interm_en = cgol.ArnoldCatEncryption(board)
            # add_image_to_list(images, board, cfg["display"])
            add_images_to_list(images, interm_en, cfg["display"])
            board, interm_de = cgol.ArnoldCatDecryption(board)
            add_images_to_list(images, interm_de, cfg["display"])

          # Record stats
          cgol_iterations += tq.format_dict['total']
          cgol_elapsed_time += tq.format_dict['elapsed']
        add_image_to_list(images, board, cfg["display"]) # Add last frame
        print(f'\n\nLength of Images is: {len(images)}\n\n')
        # Save game as a GIF
        cgol.save_gif(images, os.path.join(output_dir, expected_fout), frame_dur=cfg['display']['frame_dur_ms'])
        send_game_check(fout, board, width) # Send output check

      # Generate the trace for this game: check every frame a long the way
      elif game["checks"] == "all":
        print(f'Generating expected result "{expected_fout}" ...')
        images = []
        # Simulate Game of Life
        with tqdm(range(game['length']), disable=False) as tq:
          for i in tq:
            fout.write(f'# Checking frame {i+1}:\n')
            send_game_req(fout, board, 1, width, max_len) # Send next frame data (length=1)
            add_image_to_list(images, board, cfg["display"])

            # board = cgol.cgol_iter3(board)
            board = cgol.ArnoldCatEncryption(board)
            add_image_to_list(images, board, cfg["display"])
            board = cgol.ArnoldCatDecryption(board)

            send_game_check(fout, board, width) # Send output check
        add_image_to_list(images, board, cfg["display"]) # Add last frame
        # Save output image
        cgol.save_gif(images, os.path.join(output_dir, expected_fout), frame_dur=cfg['display']['frame_dur_ms'])
      
      # Invalid option
      else:
        assert False, f'ERROR: invalid "checks" option: {game["checks"]}'
    
    # After all games finished...
    fout.write(f'########## SIMULATION FINISHED ##########\n')
    fout.write(f'0011____0_00000000000_{64*"0"}\n')
  
  # After output file closed...
  print('Done.')
  print()

  # Print performancs stats

  print('CGoL script performance: (measured with "checks=last" games only)')
  print(f'   Computed and saved a total of {cgol_iterations} CGoL frames of size {width}x{width} over {cgol_elapsed_time:.3f} seconds')
  if cgol_elapsed_time==0 : cgol_elapsed_time = float('nan') # Handle case where there were no 'last' games
  print(f'   Average performance {cgol_iterations/cgol_elapsed_time:.3f} frames/second')
  print()

if __name__ == '__main__':
  main()
